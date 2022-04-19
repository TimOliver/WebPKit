//
//  Data+WebPDecoding.swift
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

/// Extends the Foundation Data class with
/// functionality for identifying WebP formatted data.
public extension Data {

    /// Checks the contents of the data to see if the
    /// header matches that of the WebP file format.
    var isWebP: Bool {
        // Ensure the size of the data is large enough
        // for us to properly check.
        guard self.count >= 12 else {
            return false
        }

        return withUnsafeBytes { bytes in
            // The first 4 bytes are the ASCII letters "RIFF"
            // Skipping 4 bytes for the file size, the next 4 bytes after
            // that should read "WEBP"
            if String(decoding: bytes[0..<4], as: UTF8.self) != "RIFF" ||
                String(decoding: bytes[8..<12], as: UTF8.self) != "WEBP" {
                return false
            }
            
            return true
        }
    }
}
