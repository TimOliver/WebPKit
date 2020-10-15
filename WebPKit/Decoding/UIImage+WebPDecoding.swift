//
//  UIImage+WebPDecoding.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 15/10/20.
//

import Foundation

#if canImport(UIKit)
import UIKit

#if canImport(WatchKit)
import WatchKit
#endif

/// A global image cache that stores and serves images
/// created with "webpNamed"
let imageCache = NSMapTable<NSString, UIImage>(keyOptions: .strongMemory,
                                                valueOptions: .weakMemory)

extension UIImage {

    /// Create a new image object by the decoding
    /// data in the WebP format
    /// - Parameters:
    ///   - webpData: The WebP encoded data to decode
    ///   - scale: The scale factor to scale the content to.
    ///            If nil is specified, the screen scale is used
    convenience init?(webpData: Data, scale: CGFloat? = nil) {
        guard let cgImage = try? CGImage.webpImage(data: webpData) else { return nil }
        #if os(watchOS)
        let imageScale = WKInterfaceDevice.current().screenScale
        #else
        let imageScale = scale ?? UIScreen.main.scale
        #endif
        self.init(cgImage: cgImage, scale: imageScale, orientation: .up)
    }

    /// Create a new image object by the decoding
    /// data in the WebP format on disk
    /// - Parameters:
    ///   - url: The WebP file to decode
    ///   - scale: The scale factor to scale the content to.
    ///            If nil is specified, the screen scale is used
    convenience init?(contentsOfWebPFile url: URL, scale: CGFloat? = nil) {
        guard let cgImage = try? CGImage.webpImage(contentsOfFile: url) else { return nil }
        #if os(watchOS)
        let imageScale = WKInterfaceDevice.current().screenScale
        #else
        let imageScale = scale ?? UIScreen.main.scale
        #endif
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
        // Check to see if we're on a Retina Display
        #if os(watchOS)
        let scale = Int(WKInterfaceDevice.current().screenScale)
        #else
        let scale = Int(UIScreen.main.scale)
        #endif
        var scaleSuffix = ""
        if scale > 1 {
            scaleSuffix = "@\(scale)x"
        }

        // Work out the file extension
        var pathExtension = (name as NSString).pathExtension
        if pathExtension.isEmpty { pathExtension = "webp" }

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
