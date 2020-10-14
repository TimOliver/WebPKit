//
//  WebPDecodingImageTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 15/10/20.
//

import XCTest
import UIKit

class WebPDecodingImageTests: XCTestCase {

    /// The bundle hosting these tests
    lazy var testBundle: Bundle = {
        return Bundle(for: type(of: self))
    }()

    /// A file URL to a lossless WebP test file
    lazy var losslessWebPFileURL: URL = {
        return testBundle.url(forResource: "logo-lossless", withExtension: "webp")!
    }()

    /// A file URL to a lossless WebP test file
    lazy var lossyWebPFileURL: URL = {
        return testBundle.url(forResource: "logo-lossy", withExtension: "WEBP")!
    }()

    // Test retrieving the size of the images
    func testDecodingImageSizes() {
        let losslessSize = CGImage.sizeOfWebP(at: losslessWebPFileURL)
        XCTAssertNotNil(losslessSize)
        XCTAssert(losslessSize!.width > 0 && losslessSize!.height > 0)

        let lossySize = CGImage.sizeOfWebP(at: lossyWebPFileURL)
        XCTAssertNotNil(lossySize)
        XCTAssert(lossySize!.width > 0 && lossySize!.height > 0)
    }

    // Test checking the file's path extension
    func testDecodingImages() throws {
        _ = try CGImage.webpImage(contentsOf: losslessWebPFileURL)
        _ = try CGImage.webpImage(contentsOf: lossyWebPFileURL)
    }
}
