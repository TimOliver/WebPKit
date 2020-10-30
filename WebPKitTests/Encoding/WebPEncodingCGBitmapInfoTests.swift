//
//  WebPEncodingCGBitmapInfoTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 20/10/20.
//

import XCTest

class WebPEncodingCGBitmapInfoTests: WebPEncodingTests {

    func testRGBAImages() throws {
        XCTAssertEqual(grayscaleTransparentPNGImage.pixelFormat, .grayscaleAlpha)
        XCTAssertEqual(opaqueJPEGImage.pixelFormat, .rgbx)
        XCTAssertEqual(opaquePNGImage.pixelFormat, .rgbx)
        XCTAssertEqual(transparentPNGImage.pixelFormat, .rgba)
        XCTAssertEqual(indexedTransparentPNGImage.pixelFormat, .rgba)
    }
}
