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
}
