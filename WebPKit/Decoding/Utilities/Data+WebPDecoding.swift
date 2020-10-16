//
//  Data+WebPDecoding.swift
//  WebPKit
//
//  Created by Tim Oliver on 15/10/20.
//

import Foundation

/// Extends the Foundation Data class with
/// functionality for identifying WebP formatted data.
extension Data {

    /// Checks the contents of the data to see if the
    /// header matches that of the WebP file format.
    public var isWebPFormat: Bool {
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
