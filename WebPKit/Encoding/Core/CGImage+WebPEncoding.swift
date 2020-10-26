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

        return Data()
    }
}

#endif
