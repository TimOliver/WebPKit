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

// --------------------------------------------------------------

NSString * const WebPImageErrorDomain = @"com.webp.image.error";

// --------------------------------------------------------------

static char *WebPDescriptionForVP8StatusCode(VP8StatusCode status) {
    switch (status) {
        case VP8_STATUS_OUT_OF_MEMORY: return "VP8 out of memory";
        case VP8_STATUS_INVALID_PARAM: return "VP8 invalid parameter";
        case VP8_STATUS_BITSTREAM_ERROR: return "VP8 bitstream error";
        case VP8_STATUS_UNSUPPORTED_FEATURE: return "VP8 unsupported feature";
        case VP8_STATUS_SUSPENDED: return "VP8 suspended";
        case VP8_STATUS_USER_ABORT: return "VP8 user Abort";
        case VP8_STATUS_NOT_ENOUGH_DATA: return "VP8 not enough data";
        case VP8_STATUS_OK: return "VP8 unknown error";
    }
}

// --------------------------------------------------------------

static void WebPFreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

// --------------------------------------------------------------

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
    if (data == NULL) { return NULL; }

    char *errorMessage = NULL;
    {
        WebPDecoderConfig config;
        int width = 0; int height = 0;

        const uint8_t *bytes = CFDataGetBytePtr(data);
        size_t length = CFDataGetLength(data);

        // Verify this is a valid WebP file
        if (!WebPGetInfo(bytes, length, &width, &height)) {
            errorMessage = "Unable to read header of WebP file.";
            goto _error;
        }

        // Initialize the config for storing the decoding options
        if (!WebPInitDecoderConfig(&config)) {
            errorMessage = "Failed to initialize WebP decoding configuration.";
            goto _error;
        }

        // Perform general decoding configuration
        config.output.colorspace = MODE_RGBA;
        config.options.bypass_filtering = true;
        config.options.no_fancy_upsampling = true;
        config.options.use_threads = true;

        // Perform the decode operation
        VP8StatusCode status = WebPDecode(bytes, length, &config);
        if (status != VP8_STATUS_OK) {
            errorMessage = WebPDescriptionForVP8StatusCode(status);
            goto _error;
        }

        // Convert the pixel data to a CGImageRef
        size_t bitsPerComponent = 8;
        size_t bitsPerPixel = 32;
        size_t bytesPerRow = 4;

        CGDataProviderRef provider = CGDataProviderCreateWithData(&config,
                                                                  config.output.u.RGBA.rgba,
                                                                  config.output.width * config.output.height * bytesPerRow,
                                                                  WebPFreeImageData);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
        CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
        BOOL shouldInterpolate = YES;

        CGImageRef imageRef = CGImageCreate((size_t)config.output.width, (size_t)config.output.height, bitsPerComponent, bitsPerPixel, bytesPerRow * config.output.width, colorSpace, bitmapInfo, provider, NULL, shouldInterpolate, renderingIntent);

        CGColorSpaceRelease(colorSpace);
        CGDataProviderRelease(provider);

        return imageRef;

    }
    _error: {

        return nil;
    }
}
