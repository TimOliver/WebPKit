//
//  CGImage+WebPDecoding.m
//  CocoaWebP
//
//  Created by Tim Oliver on 12/9/20.
//

#import "CGImage+WebPDecoding.h"

#if __has_include("WebP/decode.h")
#import "WebP/decode.h"
#elif __has_include(<WebP/decode.h>)
#import <WebP/decode.h>
#elif __has_include("WebPDecoder/decode.h")
#import "WebPDecoder/decode.h"
#elif __has_include(<WebPDecoder/decode.h>)
#import <WebPDecoder/decode.h>
#elif __has_include("webp/decode.h")
#import "webp/decode.h"
#elif __has_include(<libwebp/decode.h>)
#import <libwebp/decode.h>
#else
@import WebP.Decoder;
#endif

BOOL CGImageGetInfoWithWebPData(CFDataRef _Nonnull data, CGSize * _Nullable size)
{
    if (data == NULL) { return NO; }

    const UInt8 *bytes = CFDataGetBytePtr(data);
    CFIndex length = CFDataGetLength(data);
    int width = 0; int height = 0;
    if (!WebPGetInfo(bytes, length, &width, &height)) { return NO; }

    if (size != NULL) {
        size->width = (CGFloat)width;
        size->height = (CGFloat)height;
    }

    return YES;
}

__attribute__((overloadable)) CGImageRef _Nullable CGImageWithWebPData(CFDataRef _Nonnull data)
{
    return CGImageWithWebPData(data, CGSizeZero, nil);
}

__attribute__((overloadable)) CGImageRef CGImageWithWebPData(CFDataRef data,
                                                                       CGSize fittingSize,
                                                                       CFErrorRef *error)
{
    return nil;
}
