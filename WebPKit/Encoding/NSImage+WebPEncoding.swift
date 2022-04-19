//
//  NSImage+WebPEncoding.swift
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

#if canImport(AppKit)
import AppKit

/// Extends NSImage with the ability to write WebP images
public extension NSImage {

    /// Returns the image as a lossy WebP file.
    /// - Parameters:
    ///   - preset: A preset that helps configure the encoder for the type of picture.
    ///   - quality: The encoding quality of the picture. (Between 0-100)
    /// - Returns: An encoded WebP image file
    func webpData(preset: WebPEncodePreset = .default, quality: Float = 100) throws -> Data {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw WebPEncodingError.nilImage
        }
        return try cgImage.webpData(preset: preset, quality: quality)
    }

    /// Returns the image as a lossless WebP file.
    /// - Parameters:
    ///   - losslessLevel: The desired efficiency level of the image encoding.
    ///                     Between 0 (fastest, lowest compression) and 9 (slower, best compression).
    ///                     A good default level is '6', providing a fair tradeoff between compression
    ///                     speed and final compressed size.
    /// - Returns: An encoded WebP image file
    func webpLosslessData(level: Int = 6) throws -> Data {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw WebPEncodingError.nilImage
        }
        return try cgImage.webpLosslessData(level: level)
    }
}

#endif
