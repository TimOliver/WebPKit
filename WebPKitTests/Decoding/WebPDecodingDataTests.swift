//
//  WebPDecodingDataTests.swift
//  WebPKit
//
//  Created by Tim Oliver on 15/10/20.
//

import XCTest

class WebPDecodingDataTests: XCTestCase {

    /// The bundle hosting these tests
    lazy var testBundle: Bundle = {
        return Bundle(for: type(of: self))
    }()

    /// A file URL to a lossless WebP test file
    lazy var losslessWebPFileData: Data = {
        let url = testBundle.url(forResource: "logo-lossless", withExtension: "webp")!
        return try! Data(contentsOf: url, options: .alwaysMapped)
    }()

    /// A file URL to a lossless WebP test file
    lazy var lossyWebPFileURL: Data = {
        let url = testBundle.url(forResource: "logo-lossy", withExtension: "WEBP")!
        return try! Data(contentsOf: url, options: .alwaysMapped)
    }()

    // Test checking the file's path extension
    func testDataContentsCheck() {
        XCTAssertTrue(losslessWebPFileData.isWebPFormat)
        XCTAssertTrue(lossyWebPFileURL.isWebPFormat)
    }
}
