//
//  CGImage+PixelFormat.swift
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

import CoreFoundation
import CoreGraphics

extension CGImage {

    /// The different types of color pixel combinations
    /// that this image may be composed by
    public enum PixelFormat {
        case grayscale // Grayscale
        case grayscaleAlpha // Grayscale with alpha
        case rgb    // Red, Green, Blue
        case bgr    // Blue, Green, Red
        case abgr   // Alpha, Blue, Green, Red
        case argb   // Alpha, Red, Green, Blue
        case rgba   // Red, Green, Blue, Alpha
        case rgbx   // Red, Green, Blue, Alpha skipped
        case bgra   // Blue, Green, Red, Alpha
        case bgrx   // Blue, Green, Red, Alpha skipped
    }

    /// Returns the pixel format for this image
    public var pixelFormat: PixelFormat? {

        // See how many colors is encoded in this image
        guard let numberOfColorComponents = colorSpace?.numberOfComponents else { return nil }

        // HasAlpha - if it has any usable alpha data (eg, skipped alpha channels don't count)
        let hasAlpha: Bool = !(alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast)

        // AlphaFirst – the alpha channel is next to the red channel, argb and bgra are both alpha first formats.
        let alphaFirst: Bool = alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst

        // AlphaLast – the alpha channel is next to the blue channel, rgba and abgr are both alpha last formats.
        let alphaLast: Bool = alphaInfo == .premultipliedLast || alphaInfo == .last || alphaInfo == .noneSkipLast

        // LittleEndian – blue comes before red, bgra and abgr are little endian formats.
        // Little endian ordered pixels are BGR (BGRX, XBGR, BGRA, ABGR, BGR).
        // BigEndian – red comes before blue, argb and rgba are big endian formats.
        // Big endian ordered pixels are RGB (XRGB, RGBX, ARGB, RGBA, RGB).
        let endianLittle: Bool = bitmapInfo.contains(.byteOrder32Little)

        // Check if this image only has 1 component (Either grayscale or alpha)
        if numberOfColorComponents == 1 { return hasAlpha ? .grayscaleAlpha : .grayscale }

        // Anything other than 3 colors is unsupported at this time
        if numberOfColorComponents != 3 { return nil }

        // Determine the pixel format of this image, with alpha
        if alphaFirst && endianLittle {
            return hasAlpha ? .bgra : .bgrx
        } else if alphaFirst {
            return .argb
        } else if alphaLast && endianLittle {
            return .abgr
        } else if alphaLast {
            return hasAlpha ? .rgba : .rgbx
        } else if hasAlpha == false {
            return endianLittle ? .bgr : .rgb
        }

        // The format isn't recognized
        return nil
    }
}
