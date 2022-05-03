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

    // Test decoding the image with aspect fit
    func testDecodingImagesAspectFitSizing() throws {
        // Test aspect horizontal scaling by width alone
        let firstImage = try CGImage.webpImage(contentsOfFile: horizontalRectWebPFileURL, width: 64)
        XCTAssertEqual(firstImage.width, 64)
        XCTAssertEqual(firstImage.height, 32)

        // Test aspect horizontal scaling by height alone
        let secondImage = try CGImage.webpImage(contentsOfFile: horizontalRectWebPFileURL, height: 32)
        XCTAssertEqual(secondImage.width, 64)
        XCTAssertEqual(secondImage.height, 32)

        // Test aspect vertical scaling by width alone
        let thirdImage = try CGImage.webpImage(contentsOfFile: verticalRectWebPFileURL, width: 32)
        XCTAssertEqual(thirdImage.width, 32)
        XCTAssertEqual(thirdImage.height, 64)

        // Test aspect vertical scaling by height alone
        let fourthImage = try CGImage.webpImage(contentsOfFile: verticalRectWebPFileURL, height: 64)
        XCTAssertEqual(fourthImage.width, 32)
        XCTAssertEqual(fourthImage.height, 64)

        // Test horizontal with 2 values
        let fifthImage = try CGImage.webpImage(contentsOfFile: horizontalRectWebPFileURL, width: 75, height: 32)
        XCTAssertEqual(fifthImage.height, 32)
        XCTAssertEqual(fifthImage.width, 64)

        // Test vertical with 2 values
        let sixthImage = try CGImage.webpImage(contentsOfFile: verticalRectWebPFileURL, width: 75, height: 32)
        XCTAssertEqual(sixthImage.height, 32)
        XCTAssertEqual(sixthImage.width, 16)
    }

    // Test decoding the image with aspect fit
    func testDecodingImagesAspectFillSizing() throws {
        // Test aspect horizontal scaling by width alone
        let firstImage = try CGImage.webpImage(contentsOfFile: horizontalRectWebPFileURL,
                                               width: 64, scalingMode: .aspectFill)
        XCTAssertEqual(firstImage.width, 64)
        XCTAssertEqual(firstImage.height, 32)

        // Test aspect horizontal scaling by height alone
        let secondImage = try CGImage.webpImage(contentsOfFile: horizontalRectWebPFileURL,
                                                height: 32, scalingMode: .aspectFill)
        XCTAssertEqual(secondImage.width, 64)
        XCTAssertEqual(secondImage.height, 32)

        // Test aspect vertical scaling by width alone
        let thirdImage = try CGImage.webpImage(contentsOfFile: verticalRectWebPFileURL,
                                               width: 32, scalingMode: .aspectFill)
        XCTAssertEqual(thirdImage.width, 32)
        XCTAssertEqual(thirdImage.height, 64)

        // Test aspect vertical scaling by height alone
        let fourthImage = try CGImage.webpImage(contentsOfFile: verticalRectWebPFileURL,
                                                height: 64, scalingMode: .aspectFill)
        XCTAssertEqual(fourthImage.width, 32)
        XCTAssertEqual(fourthImage.height, 64)

        // Test horizontal with 2 values
        let fifthImage = try CGImage.webpImage(contentsOfFile: horizontalRectWebPFileURL,
                                               width: 75, height: 32, scalingMode: .aspectFill)
        XCTAssertEqual(fifthImage.height, 37)
        XCTAssertEqual(fifthImage.width, 75)

        // Test vertical with 2 values
        let sixthImage = try CGImage.webpImage(contentsOfFile: verticalRectWebPFileURL,
                                               width: 64, height: 32, scalingMode: .aspectFill)
        XCTAssertEqual(sixthImage.height, 128)
        XCTAssertEqual(sixthImage.width, 64)
    }
}
