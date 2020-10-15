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
        XCTAssertNotNil(UIImage.webpNamed("logo-lossy.WEBP", bundle: testBundle))
        XCTAssertNotNil(UIImage.webpNamed("logo-lossless", bundle: testBundle))
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
