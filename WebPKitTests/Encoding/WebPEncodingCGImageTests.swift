//
//  WebPEncodingCGImageTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 18/10/20.
//

import XCTest
import CoreGraphics

class WebPEncodingCGImageTests: WebPEncodingTests {

    func testEncodingLossyWebP() throws {
        var data = try opaqueJPEGImage.webpData()
        XCTAssertNotNil(data)

        data = try transparentPNGImage.webpData(preset: .text, quality: 50)
        XCTAssertNotNil(data)
    }

    func testEncodingLosslessWebP() throws {
        var data = try opaqueJPEGImage.webpLosslessData()
        XCTAssertNotNil(data)

        data = try grayscaleTransparentPNGImage.webpLosslessData(level: 1)
        XCTAssertNotNil(data)
    }
}
