//
//  CGImage+WebPDecoding.swift
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

#if canImport(WebP)
import WebP.Decoder
#elseif canImport(libwebp)
import libwebp
#else
#error("libwebp couldn't be found")
#endif

/// Errors that can potentially occur when
/// tying to decode WebP data
public enum WebPDecodingError: UInt32, Error {
    // VP8_STATUS errors
    case ok=0
    case outOfMemory
    case invalidParam
    case bitstreamError
    case unsupportedFeature
    case suspended
    case userAbort
    case notEnoughData

    // CGImage decode errors
    case invalidHeader=100
    case initConfigFailed
    case imageRenderFailed
}

/// The different scaling behaviours available
/// when optionally decoding WebP images to custom sizes.
public enum WebPScalingMode {
    case aspectFit  // Scaled to fit the size, preserving aspect ratio
    case aspectFill // Scaled to fill the size, preserving aspect ratio
    case scale      // Scaled to fill the size, disregarding aspect ratio
}

/// Extends CGImage with the ability
/// to decode images from the WebP file format
public extension CGImage {

    /// Reads the header of a WebP image file and extracts
    /// the pixel resolution of the image without performing a full decode.
    /// - Parameter url: The file URL of the WebP image
    /// - Returns: The size of the image, or nil if it failed
    static func sizeOfWebP(at url: URL)  -> CGSize? {
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else {
            return nil
        }
        return CGImage.sizeOfWebP(with: data)
    }

    /// Reads the header of a WebP image file and extracts
    /// the pixel resolution of the image without performing a full decode.
    /// - Parameter data: The WebP image data
    /// - Returns: The size of the image, or nil if it failed
    static func sizeOfWebP(with data: Data) -> CGSize? {
        var width: Int32 = 0, height: Int32 = 0

        if !data.withUnsafeBytes({ bytes -> Bool in
            guard let boundPtr = bytes.baseAddress?
                    .assumingMemoryBound(to: UInt8.self) else { return false }
            return (WebPGetInfo(boundPtr, bytes.count, &width, &height) != 0)
        }) { return nil }

        return CGSize(width: Int(width), height: Int(height))
    }

    /// Decode a WebP image from a file on disk and return it as a CGImage
    /// - Parameter url: The URL path to the file
    /// - Throws: If the data was unabled to be decoded
    /// - Returns: The decoded image as a CGImage
    static func webpImage(contentsOfFile url: URL,
                                 width: CGFloat? = nil,
                                 height: CGFloat? = nil,
                                 scalingMode: WebPScalingMode = .aspectFit) throws -> CGImage {
        let data = try Data(contentsOf: url, options: .alwaysMapped)
        return try CGImage.webpImage(data: data, width: width,
                                     height: height, scalingMode: scalingMode)
    }

    /// Decode a WebP image from memory and return it as a CGImage
    /// - Parameter data: The data to decode
    /// - Throws: If the data was unabled to be decoded
    /// - Returns: The decoded image as a CGImage
    static func webpImage(data: Data,
                                 width: CGFloat? = nil,
                                 height: CGFloat? = nil,
                                 scalingMode: WebPScalingMode = .aspectFit) throws -> CGImage {
        // Check the header before proceeding to ensure this is a valid WebP file
        guard data.isWebP else { throw WebPDecodingError.invalidHeader }

        // Get properties of WebP image so we can
        // configure the decoding as needed
        var features = WebPBitstreamFeatures()
        var status = data.withUnsafeBytes { ptr -> VP8StatusCode in
            guard let boundPtr = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return VP8_STATUS_INVALID_PARAM }
            return WebPGetFeatures(boundPtr, ptr.count, &features)
        }
        guard status == VP8_STATUS_OK else { throw WebPDecodingError(rawValue: status.rawValue)! }

        // Init the config
        var config = WebPDecoderConfig()
        guard WebPInitDecoderConfig(&config) != 0 else { throw WebPDecodingError.initConfigFailed }
        config.output.colorspace = MODE_rgbA // Pre-multipled alpha (Alpha channel is disregarded for opaque images)
        config.options.bypass_filtering = 1
        config.options.no_fancy_upsampling = 1
        config.options.use_threads = 1

        // If desired, set the config to decode at a custom size
        if width != nil || height != nil {
            // Fetch the size of the image so we can calculate aspect ratio
            let originalSize = CGSize(width: Int(features.width), height: Int(features.height))

            // Configure the target size, using the original size as default
            var size = CGSize.zero
            if scalingMode == .aspectFit { // Shrink the image to fit inside the provided size
                let scaleSize = CGSize(width: width ?? originalSize.width, height: height ?? originalSize.height)
                let scale = min(1.0, min(scaleSize.width/originalSize.width, scaleSize.height/originalSize.height))
                size.width = originalSize.width * scale
                size.height = originalSize.height * scale
            } else if scalingMode == .aspectFill { // Shrink the image to completely fill the provided size
                let scaleSize = CGSize(width: min(originalSize.width, width ?? 0), height: min(originalSize.height, height ?? 0))
                let scale = max(scaleSize.width/originalSize.width, scaleSize.height/originalSize.height)
                size.width = originalSize.width * scale
                size.height = originalSize.height * scale
            }

            // Set the config to use custom scale decoding,
            // and supply the calculated sizes
            config.options.use_scaling = 1
            config.options.scaled_width = Int32(size.width)
            config.options.scaled_height = Int32(size.height)
        }

        // Decode the image
        status = data.withUnsafeBytes { ptr -> VP8StatusCode in
            guard let boundPtr = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return VP8_STATUS_INVALID_PARAM }
            return WebPDecode(boundPtr, ptr.count, &config)
        }
        guard status == VP8_STATUS_OK else { throw WebPDecodingError(rawValue: status.rawValue)! }

        // Convert the decoded pixel data to a CGImage
        let releaseData: CGDataProviderReleaseDataCallback = {info, data, size in data.deallocate() }
        let bytesPerRow = 4
        let dataProvider = CGDataProvider(dataInfo: &config,
                                          data: config.output.u.RGBA.rgba,
                                          size: Int(config.output.width * config.output.height) * bytesPerRow,
                                          releaseData: releaseData)

        // Configure the rendering information for the image
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= features.has_alpha == 1 ? CGImageAlphaInfo.premultipliedLast.rawValue :
                                                CGImageAlphaInfo.noneSkipLast.rawValue
        let renderingIntent = CGColorRenderingIntent.defaultIntent

        // Render the image
        guard let imageRef = CGImage(width: Int(config.output.width),
                               height: Int(config.output.height),
                               bitsPerComponent: 8,
                               bitsPerPixel: 32,
                               bytesPerRow: 4 * Int(config.output.width),
                               space: colorspace,
                               bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
                               provider: dataProvider!,
                               decode: nil,
                               shouldInterpolate: false,
                               intent: renderingIntent) else { throw WebPDecodingError.imageRenderFailed }

        return imageRef
    }
}
