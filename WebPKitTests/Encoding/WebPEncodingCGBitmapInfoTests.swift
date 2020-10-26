//
//  WebPEncodingCGBitmapInfoTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 20/10/20.
//

import XCTest
import WebPKit

class WebPEncodingCGBitmapInfoTests: WebPEncodingTests {

    func testRGBAImages() throws {
        XCTAssertEqual(grayscaleTransparentPNGImage.pixelFormat, .grayscaleAlpha)
        XCTAssertEqual(opaqueJPEGImage.pixelFormat, .rgb)
        XCTAssertEqual(opaquePNGImage.pixelFormat, .rgb)
        XCTAssertEqual(transparentPNGImage.pixelFormat, .rgba)
        XCTAssertEqual(indexedTransparentPNGImage.pixelFormat, .rgba)
    }

    // Test if the images alpha properties are correct
    func testAlphaImages() {
        XCTAssertFalse(opaquePNGImage.hasAlpha)
        XCTAssertFalse(opaqueJPEGImage.hasAlpha)
        XCTAssertTrue(transparentPNGImage.hasAlpha)
        XCTAssertTrue(grayscaleTransparentPNGImage.hasAlpha)
        XCTAssertTrue(indexedTransparentPNGImage.hasAlpha)
    }
}
