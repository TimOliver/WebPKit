//
//  CGImage+WebPEncoding.swift
//  WebPKitExample-iOS
//
//  Created by Tim Oliver on 18/10/20.
//

import Foundation
import CoreGraphics
import Accelerate

#if canImport(WebP)
import WebP

/// Presets that can be used to help
/// configure how an image is encoded to WebP
enum WebPEncodePreset: UInt32 {
    case `default`=0  // The default preset
    case picture      // Digital pictures, like portraits, or inner shots
    case photo        // Outdoor photographs, with natural lighting
    case drawing      // Hand or line drawing, with high-contrast details
    case icon         // Small-sized colorful images
    case text
}

public enum WebPEncodingError: UInt32, Error {
    case outOfMemory=0
    case bitstreamOutOfMemory
    case nullParameter
    case invalidConfiguration
    case badDimension
    case partition0Overflow
    case partitionOverflow
    case badWrite
    case fileTooBig
    case userAbort

    // CGImage encode errors
    case initConfigFailed=100
    case invalidConfig
    case initPictureFailed
    case imageRenderFailed
}

/// Extends CGImage with the ability
/// to write WebP images
extension CGImage {

    public func webpData() throws -> Data {

        // Create an encoding config
        var config = WebPConfig()

        // Configure the preset with a preset and target qualitys
        if WebPConfigPreset(&config, WebPPreset(rawValue: WebPEncodePreset.picture.rawValue), 100) == 0 {
            throw WebPEncodingError.initConfigFailed
        }

        // Verify the config
        if WebPValidateConfig(&config) == 0 { throw WebPEncodingError.invalidConfig }

        // Create a picture object to encode
        var picture = WebPPicture()
        if WebPPictureInit(&picture) == 0 { throw WebPEncodingError.initPictureFailed }

        // Configure the picture with this image size
        picture.width = Int32(width)
        picture.height = Int32(height)

        // Allocate the memory for this
        if let yuvData = yuvPixelData, let yuv = yuvData.yuv {
            // Lock the base address of the data
            CVPixelBufferLockBaseAddress(yuv, .readOnly)

            // Fetch Y plane
            let yAddress = CVPixelBufferGetBaseAddressOfPlane(yuv, 0)
            picture.y = yAddress?.assumingMemoryBound(to: UInt8.self)
            picture.y_stride = Int32(CVPixelBufferGetBytesPerRowOfPlane(yuv, 0))

            // Fetch U plane
            let uAddress = CVPixelBufferGetBaseAddressOfPlane(yuv, 1)
            picture.u = uAddress?.assumingMemoryBound(to: UInt8.self)

            // Fetch V plane
            let vAddress = CVPixelBufferGetBaseAddressOfPlane(yuv, 2)
            picture.v = vAddress?.assumingMemoryBound(to: UInt8.self)

            // Set stride of both
            picture.uv_stride = Int32(CVPixelBufferGetBytesPerRowOfPlane(yuv, 1))

            // Add alpha if available
            if let alpha = yuvData.alpha {
                picture.a = alpha.data!.assumingMemoryBound(to: UInt8.self)
                picture.a_stride = Int32(alpha.rowBytes)
            }
        }

        // Make a memory writer
        var writer = WebPMemoryWriter()
        WebPMemoryWriterInit(&writer)
        picture.writer = WebPMemoryWrite
        withUnsafeMutableBytes(of: &writer) { ptr in
            picture.custom_ptr = ptr.baseAddress!
        }

        WebPEncode(&config, &picture)

        let data = Data(bytes: writer.mem, count: writer.size)

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("image.webp")
        try! data.write(to: fileURL)

        return Data()
    }

}

// MARK: - YUV Color Conversion -

/// Using the capabilities of the Accelerate framework,
/// these extensions convert this image to the required YUV color
/// format for WebP's lossy image encoding.
/// Modified from https://stackoverflow.com/a/53737749/599344
extension CGImage {

    /// Return the pixel data of this image, converted to the YUV color space
    /// and separated out into planar-aligned memory buffers
    private var yuvPixelData: (yuv: CVPixelBuffer?, alpha: vImage_Buffer?)? {
        // Set the image type to be standard 420 YUV, using the complete color range
        let yuvImageFormatType = kCVPixelFormatType_420YpCbCr8PlanarFullRange;

        // Create the pixel buffer we will write the encoded data to
        var cvPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            yuvImageFormatType,
                            nil,
                            &cvPixelBuffer)
        guard cvPixelBuffer != nil else { return nil }

        // Attach additional configuration parameters to the pixel buffer
        let pbAttachments: [CFString : Any] = [
            kCVImageBufferYCbCrMatrixKey: kCVImageBufferYCbCrMatrix_ITU_R_709_2,
            kCVImageBufferColorPrimariesKey: kCVImageBufferColorPrimaries_ITU_R_709_2,
            kCVImageBufferTransferFunctionKey: kCVImageBufferTransferFunction_ITU_R_709_2,
            kCVImageBufferICCProfileKey: CGColorSpace(name: CGColorSpace.itur_709)!.iccData!,
            kCVImageBufferChromaLocationTopFieldKey: kCVImageBufferChromaLocation_Center,
            kCVImageBufferAlphaChannelIsOpaque: true,
        ]
        CVBufferSetAttachments(cvPixelBuffer!, pbAttachments as CFDictionary, CVAttachmentMode.shouldPropagate)

        // Create an configure a format descriptor of our source image
        var rgbCGImgFormat = vImage_CGImageFormat()
        rgbCGImgFormat.bitsPerComponent = UInt32(bitsPerComponent)
        rgbCGImgFormat.bitsPerPixel = UInt32(bitsPerPixel)
        rgbCGImgFormat.bitmapInfo = bitmapInfo
        rgbCGImgFormat.colorSpace = Unmanaged.passRetained(colorSpace!)

        // Set the default background color to be black
        var backgroundColor: CGFloat = 0.0

        // Initialize the source buffer, using the contents of this CGImage
        var sourceBuffer = vImage_Buffer()
        vImageBuffer_InitWithCGImage(&sourceBuffer, &rgbCGImgFormat, &backgroundColor, self, 0)

        // Define the destination image format based off our target buffer
        let cvImgFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(cvPixelBuffer).takeUnretainedValue()

        // Convert and copy the pixel data to the new buffer
        vImageBuffer_CopyToCVPixelBuffer(&sourceBuffer,
                                         &rgbCGImgFormat,
                                         cvPixelBuffer!,
                                         cvImgFormat,
                                         &backgroundColor, 0)

        // If no alpha channel is specified, return just the YUV data
        if alphaInfo != .first, alphaInfo != .last,
           alphaInfo != .premultipliedFirst, alphaInfo != .premultipliedLast { return (yuv: cvPixelBuffer, alpha: nil) }

        // Calculate how many bytes each pixel is
        let bytesPerPixel = bitsPerPixel / bitsPerComponent

        // Determine whether the alpha value is at the front or the back of each pixel value
        var alphaPosition = 0
        if alphaInfo == .last || alphaInfo == .premultipliedLast { alphaPosition = bytesPerPixel - 1 }

        // Create the pixel buffer to store the alpha channel data
        var alphaBuffer = vImage_Buffer()
        alphaBuffer.data = UnsafeMutableRawPointer.allocate(byteCount: width * height, alignment: 0)
        alphaBuffer.width = vImagePixelCount(width)
        alphaBuffer.height = vImagePixelCount(height)
        alphaBuffer.rowBytes = bytesPerRow

        // Copy the pixel data to the new buffer
        withUnsafeBytes(of: &alphaBuffer) { alphaPointer in
            var source = [Optional(UnsafeRawPointer(sourceBuffer.data.advanced(by: alphaPosition)))]
            var alpha = [alphaPointer.baseAddress?.assumingMemoryBound(to: vImage_Buffer.self)]
            vImageConvert_ChunkyToPlanar8(&source, &alpha, 1, bytesPerPixel, vImagePixelCount(width),
                                          vImagePixelCount(height), sourceBuffer.rowBytes, 0)
        }

        // Return the pixel data
        return (yuv: cvPixelBuffer, alpha: alphaBuffer)
    }
}

#endif
