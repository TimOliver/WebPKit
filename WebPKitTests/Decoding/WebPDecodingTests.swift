//
//  WebPDecodingTests.swift
//  WebPKit
//
//  Created by Tim Oliver on 15/10/20.
//

import XCTest

public class WebPDecodingTests: XCTestCase {

    /// The bundle hosting these tests
    public lazy var testBundle: Bundle = {
        return Bundle(for: type(of: self))
    }()

    /// A file URL to a lossless WebP test file
    public lazy var losslessWebPFileURL: URL = {
        return testBundle.url(forResource: "logo-lossless", withExtension: "webp")!
    }()

    /// A file URL to a lossless WebP test file
    public lazy var lossyWebPFileURL: URL = {
        return testBundle.url(forResource: "logo-lossy", withExtension: "WEBP")!
    }()

    /// A file URL to a lossless rectangle
    public lazy var horizontalRectWebPFileURL: URL = {
        return testBundle.url(forResource: "rect-horizontal", withExtension: "webp")!
    }()

    /// A file URL to a lossless rectangle
    public lazy var verticalRectWebPFileURL: URL = {
        return testBundle.url(forResource: "rect-vertical", withExtension: "webp")!
    }()

    /// A file URL to a lossless WebP test file
    public lazy var losslessWebPFileData: Data = {
        let url = testBundle.url(forResource: "logo-lossless", withExtension: "webp")!
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else {
            fatalError("Unable to load image data from test bundle")
        }
        return data
    }()

    /// A file URL to a lossless WebP test file
    public lazy var lossyWebPFileData: Data = {
        let url = testBundle.url(forResource: "logo-lossy", withExtension: "WEBP")!
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else {
            fatalError("Unable to load image data from test bundle")
        }
        return data
    }()

}
