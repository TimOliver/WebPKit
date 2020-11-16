//
//  WebPEncodingUIImageTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 31/10/20.
//

import XCTest
import UIKit

class WebPEncodingUIImageTests: WebPEncodingTests {

    func testEmptyImage() throws {
        if (try? UIImage().webpData()) != nil {
            XCTFail("Image should have been nil")
        }
    }

    func testLossyUIImageEncoding() throws {
        // Convert image to webp data
        let image = UIImage(cgImage: opaqueJPEGImage)
        let webPData = try image.webpData(preset: .default, quality: 100)

        // Convert back to UIImage
        let decodedImage = UIImage(data: webPData)
        XCTAssertNotNil(decodedImage)

        // Check sizes match
        XCTAssertEqual(image.size, decodedImage!.size)
    }

    func testLosslessUIImageEncoding() throws {
        // Convert image to webp data
        let image = UIImage(cgImage: grayscaleTransparentPNGImage)
        let webPData = try image.webpLosslessData(level: 6)

        // Convert back to UIImage
        let decodedImage = UIImage(data: webPData)
        XCTAssertNotNil(decodedImage)

        // Check sizes match
        XCTAssertEqual(image.size, decodedImage!.size)
    }
}
