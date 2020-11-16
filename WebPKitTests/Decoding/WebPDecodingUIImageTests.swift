//
//  WebPDecodingUIImageTests.swift
//  WebPKit
//
//  Created by Tim Oliver on 15/10/20.
//

import XCTest

#if canImport(UIKit)
import UIKit

class WebPDecodingUIImageTests: WebPDecodingTests {

    // Test loading WebP files from disk
    func testLoadingUIImageFromFile() {
        XCTAssertNotNil(UIImage(contentsOfWebPFile: losslessWebPFileURL))
        XCTAssertNotNil(UIImage(contentsOfWebPFile: lossyWebPFileURL))
    }

    // Test loading WebP files from memory
    func testLoadingUIImageFromData() {
        XCTAssertNotNil(UIImage(webpData: losslessWebPFileData))
        XCTAssertNotNil(UIImage(webpData: lossyWebPFileData))
    }

    // Test loading WebP files from the resource bundle
    func testLoadingUIImageFromResourceBundle() {
        // Check lossy image
        let lossyImage = UIImage.webpNamed("logo-lossy.WEBP", bundle: testBundle)
        XCTAssertNotNil(lossyImage)

        // Compare to system WebP on iOS 14
        let lossyImageSystem = UIImage(named: "logo-lossy.WEBP", in: testBundle, with: nil)
        XCTAssertNotNil(lossyImageSystem)

        // Check both have a valid and equal size
        XCTAssertEqual(lossyImage!.size, lossyImageSystem!.size)

        // Check lossless image
        let losslessImage = UIImage.webpNamed("logo-lossless", bundle: testBundle)
        XCTAssertNotNil(losslessImage)

        let losslessImageSystem = UIImage(named: "logo-lossless.webp", in: testBundle, with: nil)
        XCTAssertNotNil(losslessImageSystem)

        XCTAssertEqual(losslessImage!.size, losslessImageSystem!.size)
    }

    // Test that images loaded multiple times point to the same instance
    func testLoadingUIImageFromResourceCache() {
        let firstImage = UIImage.webpNamed("logo-lossy.WEBP", bundle: testBundle)
        let secondImage = UIImage.webpNamed("logo-lossy.WEBP", bundle: testBundle)
        XCTAssertTrue(firstImage === secondImage)

        let thirdImage = UIImage.webpNamed("logo-lossless", bundle: testBundle)
        let fourthImage = UIImage.webpNamed("logo-lossless", bundle: testBundle)
        XCTAssertTrue(thirdImage === fourthImage)
    }
}

#endif
