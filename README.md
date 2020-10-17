# WebPKit

<img src="https://github.com/TimOliver/WebPKit/raw/master/screenshot.png" alt="WebPKit running on various devices" width="850" />

[![CI](https://github.com/TimOliver/WebPKit/workflows/CI/badge.svg)](https://github.com/TimOliver/WebPKit/actions?query=workflow%3ACI)
[![Version](https://img.shields.io/cocoapods/v/WebPKit.svg?style=flat)](http://cocoadocs.org/docsets/TOCropViewController)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/TimOliver/WebPKit/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/WebPKit.svg?style=flat)](http://cocoadocs.org/docsets/WebPKit)

WebPKit is an open source Cocoa framework that wraps the [WebP library](https://developers.google.com/speed/webp) enabling working with WebP image files on all of Apple's platforms. This allows quick and easy integration of reading (and later writing) WebP image files into your apps. It also includes advanced features such decoding WebP images to custom sizes.

# Features
* Read image files in the WebP format.
* (TODO:) Write in-memory images to the WebP format.
* Supports *all* of Apple's platforms (including Mac Catalyst).
* Additional convenience methods for quickly verifying WebP data before decoding.
* 100% Swift, and fully unit-tested.

# Requirements

* **iOS:** 9.0 and above
* **macOS:** 10.9 and above
* **tvOS:** 9.0 and above
* **watchOS:** 2.0 and above

When installing manually, you will also need Google's `WebP` C library as well. Precompiled static binaries are available at [the Cocoa-WebP repo](https://github.com/TimOliver/WebP-Cocoa).

# Installation

<details>
  <summary><strong>CocoaPods</strong></summary>
	
Add the following to your `Podfile`:

```
pod 'WebPKit'
```
	  
</details>

<details>
  <summary><strong>Carthage</strong></summary>
	
Carthage support is coming soon. Stay tuned!
</details>

<details>
  <summary><strong>Swift Package Manager</strong></summary>
	
SPM support is coming soon. Stay tuned!
</details>

<details>
  <summary><strong>Manual Installation</strong></summary>
	
	1. Download this repository.
	2. Copy the `WebPKit` folder to your Xcode project.
	3. Download the precompiled WebP binary from [the Cocoa-WebP repo](https://github.com/TimOliver/WebP-Cocoa) for your desired platform.
	4. Drag that framework into your Xcode project.
	  
</details>

# Usage

`WebPKit` provides extensions to a variety of popular Cocoa classes in order to natively provide WebP format support.

### Verifying a WebP image file

`WebPKit` provides a variety of methods to check the contents of a file or some data to see if it is a valid WebP file.

```swift
import WebPKit 

// Check a `Data` object to see if it contains WebP data
let webpData = Data(...) 
print(webp.isWebPFormat)

// Check a file on disk to see if it is a WebP file
let url = URL(...) 
print(url.isWebPFile)
```

### Decoding a WebP image

`WebPKit` performs decoding of WebP image data at the `CGImage` level, and then provides convenience initialisers for `UIImage` and `NSImage` on iOS-based platforms and macOS respectively.

#### iOS / iPadOS / tvOS / watchOS

```swift
import WebPKit 

// Load from data in memory
let webpImage = UIImage(webpData: Data()

// Load from disk
let webpImage = UIImage(contentsOfWebPFile: URL())
 
// Load from resource bundle
let webpImage = UIImage.webpNamed("MyWebPImage")
```

#### macOS

```swift
import WebPKit 

// Load from data in memory
let webpImage = NSImage(webpData: Data()

// Load from disk
let webpImage = NSImage(contentsOfWebPFile: URL())
 
// Load from resource bundle
let webpImage = NSImage.webpNamed("MyWebPImage")
```

