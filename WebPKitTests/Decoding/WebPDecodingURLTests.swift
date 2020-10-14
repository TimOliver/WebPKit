//
//  WebPKitDecodingTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 15/10/20.
//

import XCTest

class WebPDecodingURLTests: XCTestCase {

    /// The bundle hosting these tests
    lazy var testBundle: Bundle = {
        return Bundle(for: type(of: self))
    }()

    /// A file URL to a lossless WebP test file
    lazy var losslessWebPFileURL: URL = {
        return testBundle.url(forResource: "logo-lossless", withExtension: "webp")!
    }()

    /// A file URL to a lossless WebP test file
    lazy var lossyWebPFileURL: URL = {
        return testBundle.url(forResource: "logo-lossy", withExtension: "WEBP")!
    }()

    // Test checking the file's path extension
    func testFileExtensionCheck() {
        XCTAssertTrue(losslessWebPFileURL.isWebPFile)
        XCTAssertTrue(lossyWebPFileURL.isWebPFile)
    }

    // Test checking the header of each file
    func testFileContentsCheck() {
        XCTAssertTrue(losslessWebPFileURL.isWebPFile(ignoringFileExtension: true))
        XCTAssertTrue(lossyWebPFileURL.isWebPFile(ignoringFileExtension: true))
    }
}
