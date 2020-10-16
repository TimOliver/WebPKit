//
//  CGImage+WebPDecoding.swift
//  WebPKit
//
//  Created by Tim Oliver on 15/10/20.
//

import Foundation
import CoreGraphics

#if canImport(WebP)
import WebP.Decoder

/// Errors that can potentially occur when
/// tying to decode WebP data
enum WebPDecodingError: UInt32, Error {
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

/// Extends CGImage with the ability
/// to decode images from the WebP file format
extension CGImage {

    /// The different scaling behaviours available
    /// when optionally decoding WebP images to custom sizes.
    public enum WebPScalingMode {
        case aspectFit  // Scaled to fit the size, preserving aspect ratio
        case aspectFill // Scaled to fill the size, preserving aspect ratio
        case scale      // Scaled to fill the size, disregarding aspect ratio
    }

    /// Reads the header of a WebP image file and extracts
    /// the pixel resolution of the image without performing a full decode.
    /// - Parameter url: The file URL of the WebP image
    /// - Returns: The size of the image, or nil if it failed
    public static func sizeOfWebP(at url: URL)  -> CGSize? {
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else {
            return nil
        }
        return CGImage.sizeOfWebP(with: data)
    }

    /// Reads the header of a WebP image file and extracts
    /// the pixel resolution of the image without performing a full decode.
    /// - Parameter data: The WebP image data
    /// - Returns: The size of the image, or nil if it failed
    public static func sizeOfWebP(with data: Data) -> CGSize? {
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
    public static func webpImage(contentsOfFile url: URL,
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
    public static func webpImage(data: Data,
                                 width: CGFloat? = nil,
                                 height: CGFloat? = nil,
                                 scalingMode: WebPScalingMode = .aspectFit) throws -> CGImage {
        // Check the header before proceeding to ensure this is a valid WebP file
        guard data.isWebPFormat else { throw WebPDecodingError.invalidHeader }

        // Init the config
        var config = WebPDecoderConfig()
        guard WebPInitDecoderConfig(&config) != 0 else { throw WebPDecodingError.initConfigFailed }
        config.output.colorspace = MODE_rgbA;
        config.options.bypass_filtering = 1;
        config.options.no_fancy_upsampling = 1;
        config.options.use_threads = 1;

        // If desired, set the config to decode at a custom size
        if width != nil || height != nil {
            // Fetch the size of the image so we can calculate aspect ratio
            guard let originalSize = sizeOfWebP(with: data) else {
                throw WebPDecodingError.notEnoughData
            }

            // Configure the target size, using the original size as default
            var size = CGSize(width: width ?? originalSize.width,
                              height: height ?? originalSize.height)

            if scalingMode == .aspectFit {
                let scale = min(size.width/originalSize.width, size.height/originalSize.width)
                size.width = originalSize.width * scale
                size.height = originalSize.height * scale
            } else if scalingMode == .aspectFill {
                let scale = max(size.width/originalSize.width, size.height/originalSize.width)
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
        let status = data.withUnsafeBytes { ptr -> VP8StatusCode in
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

        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let renderingIntent = CGColorRenderingIntent.defaultIntent

        guard let imageRef = CGImage(width: Int(config.output.width),
                               height: Int(config.output.height),
                               bitsPerComponent: 8,
                               bitsPerPixel: 32,
                               bytesPerRow: 4 * Int(config.output.width),
                               space: colorspace,
                               bitmapInfo: bitmapInfo,
                               provider: dataProvider!,
                               decode: nil,
                               shouldInterpolate: false,
                               intent: renderingIntent) else { throw WebPDecodingError.imageRenderFailed }

        return imageRef
    }

}

#endif