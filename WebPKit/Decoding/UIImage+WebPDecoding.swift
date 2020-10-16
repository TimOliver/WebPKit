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
/// created with "webpNamed". The value is weak referenced so that
/// instances will free themselves when no external objects are retaining them.
let imageCache = NSMapTable<NSString, UIImage>(keyOptions: .strongMemory,
                                                valueOptions: .weakMemory)

extension UIImage {

    /// Create a new image object by the decoding
    /// data in the WebP format
    /// - Parameters:
    ///   - webpData: The WebP encoded data to decode
    ///   - scale: The scale factor to scale the content to.
    ///            If nil is specified, the screen scale is used.
    ///   - width: Optionally, a custom width to decode the image to.
    ///   - height: Optionally, a custom height to decode the image to.
    ///   - scalingMode: When decoding to a custom size, the type of scaling that will be applied.
    convenience init?(webpData: Data, scale: CGFloat? = nil, width: CGFloat? = nil,
                      height: CGFloat? = nil, scalingMode: CGImage.WebPScalingMode = .aspectFit) {
        // Decode the WebP image from memory
        guard let cgImage = try? CGImage.webpImage(data: webpData,
                                                   width: width,
                                                   height: height,
                                                   scalingMode: scalingMode) else { return nil }

        // Depending on platform, retrieve the screen scale
        #if os(watchOS)
        let imageScale = scale ?? WKInterfaceDevice.current().screenScale
        #else
        let imageScale = scale ?? UIScreen.main.scale
        #endif

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
    convenience init?(contentsOfWebPFile url: URL, scale: CGFloat? = nil, width: CGFloat? = nil,
                      height: CGFloat? = nil, scalingMode: CGImage.WebPScalingMode = .aspectFit) {
        // Decode the WebP image from disk
        guard let cgImage = try? CGImage.webpImage(contentsOfFile: url,
                                                   width: width,
                                                   height: height,
                                                   scalingMode: scalingMode) else { return nil }

        // Depending on platform, retrieve the screen scale
        #if os(watchOS)
        let imageScale = scale ?? WKInterfaceDevice.current().screenScale
        #else
        let imageScale = scale ?? UIScreen.main.scale
        #endif

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
        if pathExtension.isEmpty { pathExtension = "webp" }

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
