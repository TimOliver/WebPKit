//
//  WebPEncodingUIImageTests.swift
//  WebPKitTests
//
//  Created by Tim Oliver on 31/10/20.
//

import XCTest
import UIKit

class WebPEncodingUIImageTests: XCTestCase {

    func testEmptyImage() throws {
        if (try? UIImage().webpData()) != nil {
            XCTFail("Image should have been nil")
        }
    }
}
