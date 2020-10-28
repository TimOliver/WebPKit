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
    case initPictureFailed
    case configPresetFailed
    case imageRenderFailed
    case invalidPictureData
}

/// Extends CGImage with the ability
/// to write WebP images
extension CGImage {

    public func webpData() throws -> Data {

        // Create an encoding config
        var config = WebPConfig()

        // Initialize the config
        if WebPConfigInit(&config) == 0 {
            throw WebPEncodingError.initConfigFailed
        }

        // Configure the preset with a preset and target quality
        if WebPConfigPreset(&config, WebPPreset(rawValue: WebPEncodePreset.default.rawValue), 100) == 0 {
            throw WebPEncodingError.invalidConfiguration
        }

//        if WebPConfigLosslessPreset(&config, 9) == 0 {
//            throw WebPEncodingError.initConfigFailed
//        }

        // Verify the config
        if WebPValidateConfig(&config) == 0 { throw WebPEncodingError.invalidConfiguration }

        // Create a picture object to encode
        var picture = WebPPicture()
        if WebPPictureInit(&picture) == 0 { throw WebPEncodingError.initPictureFailed }

        // Configure the picture with this image size
        picture.use_argb = 1
        picture.width = Int32(width)
        picture.height = Int32(height)

        // Try to use WebP's capabilities to import our pixel data
        // into the picture struct
        if !importPixelData(into: &picture) {
            // If the data was in a color format WebP can't convert,
            // perform our own color conversion and then import the converted data
            if !importConvertedPixelData(into: &picture) {
                throw WebPEncodingError.invalidPictureData
            }
        }

        // Create a memory writer as a destination for the encoded data
        var memoryWriter = WebPMemoryWriter()
        WebPMemoryWriterInit(&memoryWriter)
        picture.writer = WebPMemoryWrite
        withUnsafePointer(to: &memoryWriter) { ptr in
            picture.custom_ptr = UnsafeMutableRawPointer(mutating: ptr)
        }

        // Perform the encoding
        let result = WebPEncode(&config, &picture)

        // Free up the picture
        WebPPictureFree(&picture)

        // Report if the conversion failed
        if result != 1 {
            throw WebPEncodingError(rawValue: picture.error_code.rawValue) ??
                    WebPEncodingError.imageRenderFailed
        }

        // Return the data
        return Data(bytes: memoryWriter.mem, count: memoryWriter.size)
    }
}

private extension CGImage {

    // If this image is already in a compatible pixel format,
    // import it into the provided WebPPicture struct using libwebp's
    // color space conversion capabilities.
    func importPixelData(into picture: inout WebPPicture) -> Bool {
        // WebP can only deal with combinations of RGB color values
        guard colorSpace?.numberOfComponents ?? 0 == 3 else { return false }

        // Check to see if this image is in a compatible pixel format before we
        // do a potentially heavy copy operation.
        let availablePixelFormats: [PixelFormat] = [.rgb, .rgba, .rgbx, .bgra, .bgrx]
        guard let pixelFormat = pixelFormat,
              availablePixelFormats.contains(pixelFormat) else { return false}

        // Now we've confirmed it's in a format we can support, fetch the data
        guard let data = dataProvider?.data else { return false }
        let bytePointer = CFDataGetBytePtr(data)
        let stride = Int32(bytesPerRow)

        // Perform the import operation
        if pixelFormat == .rgb {
            return WebPPictureImportRGB(&picture, bytePointer, stride) != 0
        } else if pixelFormat == .rgba {
            return WebPPictureImportRGBA(&picture, bytePointer, stride) != 0
        } else if pixelFormat == .rgbx {
            return WebPPictureImportRGBX(&picture, bytePointer, stride) != 0
        } else if pixelFormat == .bgra {
            return WebPPictureImportBGRA(&picture, bytePointer, stride) != 0
        } else if pixelFormat == .bgrx {
            return WebPPictureImportBGRX(&picture, bytePointer, stride) != 0
        }

        // Default to false if it failed
        return false
    }

    // If the image was in an unsupported format that WebP can't presently work with,
    // convert it to RGB(A) and then import it.
    func importConvertedPixelData(into picture: inout WebPPicture) -> Bool {
        // Capture whether we need to allocate for an alpha channel
        let hasAlpha = !(alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast)

        // Configure the buffer settings
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel

        // Allocate the pixel buffer
        let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: bytesPerRow * height)
        defer { pixels.deallocate() }

        // Configure the byte order, and include alpha if this image has it
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= hasAlpha ? CGImageAlphaInfo.premultipliedLast.rawValue : CGImageAlphaInfo.noneSkipLast.rawValue

        // Create the context
        guard let context = CGContext(data: pixels,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return false
        }

        // Draw the image into this new context
        context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        // Import the image into the WebP struct
        if hasAlpha {
            return WebPPictureImportRGBA(&picture, pixels, Int32(bytesPerRow)) != 0
        }
        return WebPPictureImportRGBX(&picture, pixels, Int32(bytesPerRow)) != 0
    }
}

#endif
