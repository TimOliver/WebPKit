//
//  CGImage+WebPEncoding.swift
//
//  Copyright 2020-2022 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreGraphics
import Accelerate

/// Presets that can be used to help
/// configure how an image is encoded to WebP
public enum WebPEncodePreset: UInt32 {
    case `default`=0  // The default preset
    case picture      // Digital pictures, like portraits, or inner shots
    case photo        // Outdoor photographs, with natural lighting
    case drawing      // Hand or line drawing, with high-contrast details
    case icon         // Small-sized colorful images
    case text         // Text based images
}

/// The list of possible errors that can occur
/// when trying to encode to WebP
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
    case nilImage
}

#if canImport(WebP)
import WebP
#elseif canImport(libwebp)
import libwebp
#else
#error("libwebp couldn't be found")
#endif

/// Extends CGImage with the ability
/// to write WebP images
extension CGImage {

    /// Returns the image as a lossy WebP file.
    /// - Parameters:
    ///   - preset: A preset that helps configure the encoder for the type of picture.
    ///   - quality: The encoding quality of the picture. (Between 0-100)
    /// - Returns: An encoded WebP image file
    public func webpData(preset: WebPEncodePreset = .default, quality: Float = 100) throws -> Data {

        // Create and initialize an encoding config
        var config = WebPConfig()
        if WebPConfigInit(&config) == 0 {
            throw WebPEncodingError.initConfigFailed
        }

        // Set up the config with a preset and target quality
        if WebPConfigPreset(&config, WebPPreset(rawValue: preset.rawValue), quality) == 0 {
            throw WebPEncodingError.invalidConfiguration
        }

        // Compress the image
        return try webpData(config: &config)
    }

    /// Returns the image as a lossless WebP file.
    /// - Parameters:
    ///   - losslessLevel: The desired efficiency level of the image encoding.
    ///                     Between 0 (fastest, lowest compression) and 9 (slower, best compression).
    ///                     A good default level is '6', providing a fair tradeoff between compression
    ///                     speed and final compressed size.
    /// - Returns: An encoded WebP image file
    public func webpLosslessData(level: Int = 6) throws -> Data {

        // Create and initialize an encoding config
        var config = WebPConfig()
        if WebPConfigInit(&config) == 0 {
            throw WebPEncodingError.initConfigFailed
        }

        // Set up the config as a lossless image with the provided level
        if WebPConfigLosslessPreset(&config, Int32(level)) == 0 {
            throw WebPEncodingError.initConfigFailed
        }

        // Compress the image
        return try webpData(config: &config)
    }

    /// Returns the image as a WebP file, as described in the provided config object.
    /// - Parameter config: A properly configured WebPConfig object to control the encoding.
    /// - Returns: An encoded WebP image file
    private func webpData(config: inout WebPConfig) throws -> Data {

        // Verify the configuration isn't invalid
        if WebPValidateConfig(&config) == 0 { throw WebPEncodingError.invalidConfiguration }

        // Create a picture object to hold the image data
        var picture = WebPPicture()
        if WebPPictureInit(&picture) == 0 { throw WebPEncodingError.initPictureFailed }
        defer { WebPPictureFree(&picture) }

        // Configure the picture with this image size
        picture.width = Int32(width)
        picture.height = Int32(height)

        // Try to use WebP's capabilities to import our pixel data
        // into the picture struct.
        if !importPixelData(into: &picture) {
            // If the data was in a color format WebP can't convert as-is,
            // perform our own color conversion and then import the converted data.
            if !importConvertedPixelData(into: &picture) {
                throw WebPEncodingError.invalidPictureData
            }
        }

        // Create a memory writer as a destination for the encoded data
        var writer = WebPMemoryWriter()
        WebPMemoryWriterInit(&writer)
        picture.writer = WebPMemoryWrite
        withUnsafePointer(to: &writer) { ptr in
            picture.custom_ptr = UnsafeMutableRawPointer(mutating: ptr)
        }

        // Perform the conversion to WebP
        if WebPEncode(&config, &picture) == 0 {
            throw WebPEncodingError(rawValue: picture.error_code.rawValue) ??
                WebPEncodingError.imageRenderFailed
        }

        // Wrap the data in a Data object that will be in
        // charge of freeing the data when done.
        return Data(bytesNoCopy: writer.mem,
                    count: writer.size,
                    deallocator: .free)
    }
}

// MARK: Private Members

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
              availablePixelFormats.contains(pixelFormat) else { return false }

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
    // perform a color conversion in Core Graphics, and then import the converted data.
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
                                      bitmapInfo: bitmapInfo) else { return false }

        // Draw the image into this new context
        context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        // Import the image into the WebP Picture struct
        if hasAlpha {
            return WebPPictureImportRGBA(&picture, pixels, Int32(bytesPerRow)) != 0
        } else {
            return WebPPictureImportRGBX(&picture, pixels, Int32(bytesPerRow)) != 0
        }
    }
}
