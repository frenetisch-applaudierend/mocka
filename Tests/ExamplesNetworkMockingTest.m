//
//  ExamplesNetworkMockingTest.m
//  mocka
//
//  Created by Markus Gasser on 25.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExamplesCommon.h"


@interface HTTPServerMock : NSObject

+ (instancetype)sharedMock;

@property (nonatomic, readonly) HTTPServerMock*(^GET)(id url);
@property (nonatomic, readonly) HTTPServerMock*(^withHeaders)(NSDictionary *headers);

@end

@implementation HTTPServerMock

+ (instancetype)sharedMock {
    return [[self alloc] init];
}

- (HTTPServerMock*(^)(id))GET {
    return ^(id url) {
        return self;
    };
}

- (HTTPServerMock*(^)(NSDictionary*))withHeaders {
    return ^(NSDictionary *headers) {
        return self;
    };
}

@end

#define Network [HTTPServerMock sharedMock]



@interface ExamplesNetworkMockingTest : XCTestCase @end
@implementation ExamplesNetworkMockingTest

#pragma mark - Test Network Call Stubbing

- (void)testYouCanStubNetworkCalls {
    // you can use the mocka DSL to stub network calls using the Network "mock"
    // it uses the OHHTTTPStubs library for this
    whenCalling Network.GET(@"http://www.google.ch").withHeaders(@{ @"Test": @200 }) thenDo returnValue(@"Hello, World!");
    
    // if you now make a call to the specified URL you'll receive the stubbed return value
    // if you use returnValue(...) then the status code 200 is implied
    NSData *received = [self GET:@"http://www.google.ch" error:NULL];
    XCTAssertEqualObjects(received, [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding], @"Wrong data was returned");
}



#pragma mark - Network Access

- (NSData *)GET:(NSString *)urlString error:(NSError **)error {
    NSParameterAssert(urlString != nil);
    
    __block NSData *responseData = nil;
    __block NSError *networkError = nil;
    __block BOOL responded = NO;
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[[self URLSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        responseData = (response != nil ? [data copy] : nil);
        networkError = (response == nil ? [error copy] : nil);
        responded = YES;
    }] resume];
    
    WaitForCondition(0.5, ^BOOL{ return responded; });
    
    if (error != NULL) { *error = networkError; }
    return responseData;
}

- (NSURLSession *)URLSession {
    return [NSURLSession sharedSession];
}

@end
