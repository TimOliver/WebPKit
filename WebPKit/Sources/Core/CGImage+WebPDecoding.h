//
//  CGImage+WebPDecoding.h
//  CocoaWebP
//
//  Created by Tim Oliver on 12/9/20.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

CF_ASSUME_NONNULL_BEGIN

/// Reads the header of a WebP image file, and provides the pixel dimensions if valid.
/// @param data The compressed WebP image data.
/// @param size An optional pointer to a `CGSize` struct that will read
BOOL CGImageGetInfoWithWebPData(CFDataRef _Nonnull data, CGSize * _Nullable size);

/// Decodes and returns a CGImage object using the specified WebP image data.
/// @param data The compressed WebP image data. Can be from a file or in-memory.
__attribute__((overloadable)) CGImageRef _Nullable CGImageWithWebPData(CFDataRef _Nonnull data);

/// Decodes a WebP image file and returns it as a CGImage.
/// @param data The complete data blob of the encoded WebP image file
/// @param fittingSize Optionally, a size to scale the image to fit during decoding
/// @param error An optional error object in case the decoding fails
__attribute__((overloadable)) CGImageRef _Nullable CGImageWithWebPData(CFDataRef _Nonnull data,
                                                                       CGSize fittingSize,
                                                                       CFErrorRef * _Nullable error);

CF_ASSUME_NONNULL_END
