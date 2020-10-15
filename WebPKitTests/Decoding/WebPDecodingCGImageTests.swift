//
//  WebPDecodingImageTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 15/10/20.
//

import XCTest

class WebPDecodingCGImageTests: WebPDecodingTests {

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
        _ = try CGImage.webpImage(contentsOfFile: losslessWebPFileURL)
        _ = try CGImage.webpImage(contentsOfFile: lossyWebPFileURL)
    }
}
