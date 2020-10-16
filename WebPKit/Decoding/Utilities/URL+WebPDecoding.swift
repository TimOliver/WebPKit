//
//  WebPDecoding.swift
//  WebPKit (macOS)
//
//  Created by Tim Oliver on 14/10/20.
//

import Foundation

/// Extends the Foundation URL class with
/// functionality for identifying WebP files.
extension URL {

    /// Returns the standard file extension for the WEBP format as a string
    public static var webpFileExtension: String { return "webp" }

    /// Returns whether this file URL points to a WebP image file.
    /// It initially checks the file name to see if it contains the WebP file extension,
    /// but if that files, it will check the contents of the file for the WebP format magic number.
    public var isWebPFile: Bool { isWebPFile(ignoringFileExtension: false) }

    /// Returns whether this file URL points to a WebP image file.
    /// It initially checks the file name to see if it contains the WebP file extension,
    /// but if that files, it will check the contents of the file for the WebP format magic number.
    /// - Parameter ignoringFileExtension: Whether to skip checking the extension and go straight to checking the contents
    /// - Returns: Whether the file is in the WebP format or not
    public func isWebPFile(ignoringFileExtension: Bool = false) -> Bool {

        // If desired, check the file format extension
        if !ignoringFileExtension && self.pathExtension.lowercased() == URL.webpFileExtension {
            return true
        }

        // Load the file as mapped memory, and check the header
        if let data = try? Data(contentsOf: self, options: .alwaysMapped) {
            return data.isWebPFormat
        }

        return false
    }

}
