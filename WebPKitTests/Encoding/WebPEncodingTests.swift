//
//  WebPEncodingTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 20/10/20.
//

import Foundation
import XCTest

class WebPEncodingTests: XCTestCase {
    /// The bundle hosting these tests
    public lazy var testBundle: Bundle = {
        return Bundle(for: type(of: self))
    }()

    /// Loads a transparent PNG as a CGImage
    public lazy var transparentPNGImage: CGImage = {
        return image(named: "circle-transparent", withExtension: "png")
    }()

    /// Loads a transparent PNG as a CGImage
    public lazy var grayscaleTransparentPNGImage: CGImage = {
        return image(named: "circle-grayscale-transparent", withExtension: "png")
    }()

    /// Loads a transparent indexed PNG as a CGImage
    public lazy var indexedTransparentPNGImage: CGImage = {
        return image(named: "circle-index-transparent", withExtension: "png")
    }()

    /// Loads a opaque PNG as a CGImage
    public lazy var opaquePNGImage: CGImage = {
        return image(named: "circle-opaque", withExtension: "png")
    }()

    /// Loads a opaque JPEG as a CGImage
    public lazy var opaqueJPEGImage: CGImage = {
        return image(named: "circle-opaque", withExtension: "jpg")
    }()
}

extension WebPEncodingTests {

    /// Return a CGImage from the image bundle
    private func image(named name: String, withExtension fileExtension: String) -> CGImage {
        let url = testBundle.url(forResource: name, withExtension: fileExtension)!
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else {
            fatalError("Could not locate file from test bundle")
        }
        let dataProvider = CGDataProvider(data: data as CFData)!
        if fileExtension == "jpg" {
            return CGImage(jpegDataProviderSource: dataProvider, decode: nil,
                           shouldInterpolate: true, intent: .defaultIntent)!
        }
        return CGImage(pngDataProviderSource: dataProvider, decode: nil,
                       shouldInterpolate: true, intent: .defaultIntent)!
    }
}
