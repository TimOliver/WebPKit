//
//  WebPKitDecodingTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 15/10/20.
//

import XCTest

class WebPDecodingURLTests: WebPDecodingTests {
    
    // Test checking the file's path extension
    func testFileExtensionCheck() {
        XCTAssertTrue(losslessWebPFileURL.isWebP)
        XCTAssertTrue(lossyWebPFileURL.isWebP)
    }

    // Test checking the header of each file
    func testFileContentsCheck() {
        XCTAssertTrue(losslessWebPFileURL.isWebP(ignoringFileExtension: true))
        XCTAssertTrue(lossyWebPFileURL.isWebP(ignoringFileExtension: true))
    }

    // Test different types of invalid URLs
    func testInvalidURLValues() {
        XCTAssertFalse(URL(string: "~/image.webp")!.isWebP(ignoringFileExtension: true))
        XCTAssertFalse(URL(string: "~/image.jpeg")!.isWebP)
        XCTAssertFalse(URL(string: "http://google.com/image.jpg")!.isWebP)
        XCTAssertFalse(URL(string: "http://google.com/image.webp")!.isWebP(ignoringFileExtension: true))
    }
}
