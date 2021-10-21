# WebPKit

<img src="https://github.com/TimOliver/WebPKit/raw/main/screenshot.png" alt="WebPKit running on various devices" width="850" />

[![CI](https://github.com/TimOliver/WebPKit/workflows/CI/badge.svg)](https://github.com/TimOliver/WebPKit/actions?query=workflow%3ACI)
[![Version](https://img.shields.io/cocoapods/v/WebPKit.svg?style=flat)](http://cocoadocs.org/docsets/TOCropViewController)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/TimOliver/WebPKit/main/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/WebPKit.svg?style=flat)](http://cocoadocs.org/docsets/WebPKit)

`WebPKit` is an open source Swift framework that wraps around Google's [WebP library](https://developers.google.com/speed/webp) to provide a native-feeling Cocoa API for working with WebP image files on all of Apple's platforms.

`WebPKit` works by extending certain Cocoa classes to enable decoding WebP image data from disk, or encoding WebP image data from memory. It also provides additional functionality such as being able to verify the contents of a WebP file before decoding, as well as using WebP's decoding features to enable custom sizing.


# Features
* Read image files in the WebP format.
* Write in-memory images to the WebP format.
* Supports *all* of Apple's platforms (including Mac Catalyst).
* Additional convenience methods for quickly verifying WebP data before decoding.
* Decode WebP images directly to custom sizes (Good for saving memory)
* 100% Swift, and fully unit-tested.

# Requirements

* **iOS:** 9.0 and above
* **macOS:** 10.9 and above
* **tvOS:** 9.0 and above
* **watchOS:** 2.0 and above

When installing manually, you will also need Google's `WebP` C library as well. Precompiled static binaries are available at [the Cocoa-WebP repo](https://github.com/TimOliver/WebP-Cocoa).

# Usage

`WebPKit` provides extensions to a variety of popular Cocoa classes in order to natively provide WebP format support.

### Verifying a WebP image file

`WebPKit` provides a variety of methods to check the contents of a file or some data to see if it is a valid WebP file.

```swift
import WebPKit 

// Check a `Data` object to see if it contains WebP data
let webpData = Data(...) 
print(webpData.isWebP)

// Check a file on disk to see if it is a WebP file
let url = URL(...) 
print(url.isWebP)

// Retrieve the pixel size of the image without decoding it
let size = CGImage.sizeOfWebP(with: Data())
```

### Decoding a WebP image

`WebPKit` performs decoding of WebP image data at the `CGImage` level, and then provides convenience initialisers for `UIImage` and `NSImage` on iOS-based platforms and macOS respectively.

#### iOS / iPadOS / tvOS / watchOS

```swift
import WebPKit 

// Load from data in memory
let webpImage = UIImage(webpData: Data())

// Load from disk
let webpImage = UIImage(contentsOfWebPFile: URL())
 
// Load from resource bundle
let webpImage = UIImage.webpNamed("MyWebPImage")
```

#### macOS

```swift
import WebPKit 

// Load from data in memory
let webpImage = NSImage(webpData: Data())

// Load from disk
let webpImage = NSImage(contentsOfWebPFile: URL())
 
// Load from resource bundle
let webpImage = NSImage.webpNamed("MyWebPImage")
```

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

# Why Build This?

Support for WebP image files had been a growing feature request in my comic reader app [iComics](http://icomics/co) for a number of years. With iComics being in Objective-C, I was able to use [one of the many libraries](https://github.com/mattt/WebPImageSerialization) on GitHub out there to easily support it.

But while that was the case for Objective-C, while I've been working on iComics 2, I started to realise that there still wasn't a great amount of WebP support for Swift, as well as Apple's modern platforms and features in general. 

Google's own precompiled WebP binaries don't support either Swift or Mac Catalyst, and while I found a few different WebP Swift libraries out there, none covered all of the requirements that I was hoping for (Things like CocoaPods support, accurate alpha channel control, and decoding at intermediate sizes).

For a feature that will be an extremely fundamental pillar in iComics 2, I decided that it would be worth the time and investment to go back and make a *really* good WebP framework from scratch, that followed the API design of Apple's frameworks for easy integration, but also gave me the control to include all of the advanced features I need from the start.

I'm incrdedibly happy with how this framework turned out. It turns out it was no where near as much code as I was expecting, and it all fit nicely as extensions on existing Apple classes. Moving forward, I hope this framework can be valuable for other Apple developers as well.

# Credits

`WebPKit` was created by [Tim Oliver](http://twitter.com/TimOliverAU).

A huge shout-out also goes to the `SDWebImage` team for [maintaining CocoaPods and Carthage releases](https://github.com/SDWebImage/libwebp-Xcode) for WebP all this time as well.

# License

`WebPKit` is licensed under the MIT License. Please see the [LICENSE](LICENSE) file for more details.
