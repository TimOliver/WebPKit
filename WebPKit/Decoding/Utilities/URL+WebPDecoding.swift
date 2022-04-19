//
//  URL+WebPDecoding.swift
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

/// Extends the Foundation URL class with
/// functionality for identifying WebP files.
public extension URL {

    /// Returns the standard file extension for the WEBP format as a string
    static var webpFileExtension: String { return "webp" }

    /// Returns whether this file URL points to a WebP image file.
    /// It initially checks the file name to see if it contains the WebP file extension,
    /// but if that files, it will check the contents of the file for the WebP format magic number.
    var isWebP: Bool { isWebP(ignoringFileExtension: false) }

    /// Returns whether this file URL points to a WebP image file.
    /// It initially checks the file name to see if it contains the WebP file extension,
    /// but if that files, it will check the contents of the file for the WebP format magic number.
    /// - Parameter ignoringFileExtension: Whether to skip checking the extension and go straight to checking the contents
    /// - Returns: Whether the file is in the WebP format or not
    func isWebP(ignoringFileExtension: Bool = false) -> Bool {

        // If desired, check the file format extension
        if !ignoringFileExtension, self.pathExtension.lowercased() == URL.webpFileExtension {
            return true
        }

        // Load the file as mapped memory, and check the header
        // Ensure we only try this on URLs representing local files on disk.
        if isFileURL, let data = try? Data(contentsOf: self, options: .alwaysMapped) {
            return data.isWebP
        }

        return false
    }

}
