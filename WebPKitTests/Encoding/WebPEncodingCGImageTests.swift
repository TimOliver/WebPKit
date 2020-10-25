//
//  WebPEncodingCGImageTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 18/10/20.
//

import XCTest
import WebPKit

class WebPEncodingCGImageTests: WebPEncodingTests {

    func testEncodingLossyWebP() throws {
        let data = try indexedTransparentPNGImage.webpData()
    }
}
