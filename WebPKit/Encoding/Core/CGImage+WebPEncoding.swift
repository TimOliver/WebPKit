//
//  CGImage+WebPEncoding.swift
//  WebPKitExample-iOS
//
//  Created by Tim Oliver on 18/10/20.
//

import Foundation
import CoreGraphics

#if canImport(WebP)
import WebP

/// Presets that can be used to help
/// configure how an image is encoded to WebP
enum WebPEncodePreset: UInt32 {
    case `default`  // The default preset
    case picture    // Digital pictures, like portraits, or inner shots
    case photo      // Outdoor photographs, with natural lighting
    case graph      // Discrete tone image (graph, map-tile etc).
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
    case imageRenderFailed
}

/// Extends CGImage with the ability
/// to write WebP images
extension CGImage {

    public func webpData() -> Data {

        // Create an encoding config
        var config = WebPConfig()

        return Data()
    }

}

#endif
