//
//  UIImage+WebPDecoding.swift
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

#if canImport(UIKit)
import UIKit

#if canImport(WatchKit)
import WatchKit
#endif

/// A global image cache that stores and serves images
/// created with "webpNamed". The value is weak referenced so that
/// instances will free themselves when no external objects are retaining them.
let imageCache = NSMapTable<NSString, UIImage>(keyOptions: .strongMemory,
                                                valueOptions: .weakMemory)

public extension UIImage {

    /// Create a new image object by the decoding
    /// data in the WebP format
    /// - Parameters:
    ///   - webpData: The WebP encoded data to decode
    ///   - scale: The scale factor to scale the content to.
    ///            If nil is specified, the screen scale is used.
    ///   - width: Optionally, a custom width to decode the image to.
    ///   - height: Optionally, a custom height to decode the image to.
    ///   - scalingMode: When decoding to a custom size, the type of scaling that will be applied.
    convenience init?(webpData: Data, scale: CGFloat? = 1.0, width: CGFloat? = nil,
                      height: CGFloat? = nil, scalingMode: WebPScalingMode = .aspectFit) {

        // Depending on platform, retrieve the screen scale
        #if os(watchOS)
        let imageScale = scale ?? WKInterfaceDevice.current().screenScale
        #else
        let imageScale = scale ?? UIScreen.main.scale
        #endif

        // Decode the WebP image from memory
        guard let cgImage = try? CGImage.webpImage(data: webpData,
                                                   width: (width != nil) ? width! * imageScale : nil,
                                                   height: (height != nil) ? height! * imageScale : nil,
                                                   scalingMode: scalingMode) else { return nil }

        // Initialize the UIImage
        self.init(cgImage: cgImage, scale: imageScale, orientation: .up)
    }

    /// Create a new image object by the decoding
    /// data in the WebP format on disk
    /// - Parameters:
    ///   - url: The WebP file to decode
    ///   - scale: The scale factor to scale the content to.
    ///            If nil is specified, the screen scale is used
    ///   - width: Optionally, a custom width to decode the image to.
    ///   - height: Optionally, a custom height to decode the image to.
    ///   - scalingMode: When decoding to a custom size, the type of scaling that will be applied.
    convenience init?(contentsOfWebPFile url: URL, scale: CGFloat? = 1.0, width: CGFloat? = nil,
                      height: CGFloat? = nil, scalingMode: WebPScalingMode = .aspectFit) {
        // Depending on platform, retrieve the screen scale
        #if os(watchOS)
        let imageScale = scale ?? WKInterfaceDevice.current().screenScale
        #else
        let imageScale = scale ?? UIScreen.main.scale
        #endif

        // Decode the WebP image from disk
        guard let cgImage = try? CGImage.webpImage(contentsOfFile: url,
                                                   width: (width != nil) ? width! * imageScale : nil,
                                                   height: (height != nil) ? height! * imageScale : nil,
                                                   scalingMode: scalingMode) else { return nil }

        // Initialize the UIImage
        self.init(cgImage: cgImage, scale: imageScale, orientation: .up)
    }

    /// Load a WebP image file from this app's resources bundle.
    /// If successfully loaded, the image is cached so it can be re-used
    /// on subsequent calls
    /// - Parameters:
    ///   - name: The WebP image's name in the resources bundle
    ///   - bundle: Optionally, the bundle to target (By default, the main bundle is used)
    /// - Returns: The decoded image if successful, or nil if not
    static func webpNamed(_ name: String, bundle: Bundle = Bundle.main) -> UIImage? {
        // Retrieve the scale of the screen
        #if os(watchOS)
        let scale = Int(WKInterfaceDevice.current().screenScale)
        #else
        let scale = Int(UIScreen.main.scale)
        #endif

        // If a scale was discovered, configure the default file name
        var scaleSuffix = ""
        if scale > 1 {
            scaleSuffix = "@\(scale)x"
        }

        // Work out the file extension
        var pathExtension = (name as NSString).pathExtension
        if pathExtension.isEmpty { pathExtension = URL.webpFileExtension }

        // Extract the file name minus the extension
        let fileName = (name as NSString).deletingPathExtension

        // Format the name to include the Retina scale suffix
        let scaleName = "\(fileName)\(scaleSuffix)" // eg 'image@2x.webp'

        // Query to see if we have a stored image in the cache
        if let image = imageCache.object(forKey: NSString(string: scaleName)) { return image }
        if let image = imageCache.object(forKey: NSString(string: fileName)) { return image }

        // Check both the scale name and regular name
        let names = [scaleName, fileName]
        for name in names {
            // If we discovered an image, load it, and save it to the cache
            if let url = bundle.resourceURL?.appendingPathComponent("\(name).\(pathExtension)"),
               let image = UIImage(contentsOfWebPFile: url) {
                imageCache.setObject(image, forKey: NSString(string: name))
                return image
            }
        }

        // Return the newly created image
        return nil
    }
}

#endif
