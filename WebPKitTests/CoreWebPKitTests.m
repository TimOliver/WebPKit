//
//  WebPKitTests.m
//  WebPKitTests
//
//  Created by Tim Oliver on 12/10/20.
//

#import <XCTest/XCTest.h>
#import "CGImage+WebPDecoding.h"

@interface CoreWebPTests : XCTestCase

@property (nonatomic, strong) NSString *imagePath;

@end

@implementation CoreWebPTests

- (void)setUp
{
    static NSString *bundleIdentifier = @"dev.tim.WebPKitExample-iOS";
    NSBundle *bundle = [NSBundle bundleWithIdentifier:bundleIdentifier];
    self.imagePath = [bundle pathForResource:@"WebPKitLogo" ofType:@"webp"];
}

- (void)testImageSize
{
    CGSize size = CGSizeZero;
    NSData *data = [NSData dataWithContentsOfFile:self.imagePath options:NSDataReadingMapped error:nil];
    CFDataRef dataRef = (CFDataRef)CFBridgingRetain(data);
    XCTAssertTrue(CGImageGetInfoWithWebPData((CFDataRef)CFBridgingRetain(data), &size));
    XCTAssertEqual(size.width, 2048);
    XCTAssertEqual(size.height, 2048);
    CFRelease(dataRef);
}

@end
