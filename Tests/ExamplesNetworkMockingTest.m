//
//  ExamplesNetworkMockingTest.m
//  mocka
//
//  Created by Markus Gasser on 25.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExamplesCommon.h"


@interface ExamplesNetworkMockingTest : XCTestCase @end
@implementation ExamplesNetworkMockingTest

#pragma mark - Test Network Call Stubbing

- (void)testYouCanStubNetworkCalls {
    // you can use the mocka DSL to stub network calls using the Network "mock"
    // it uses the OHHTTTPStubs library for this
    whenCalling Network.GET(@"http://www.google.ch") thenDo {
        returnValue([@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding]);
    };
    
    // if you now make a call to the specified URL you'll receive the stubbed return value
    // if you use returnValue(...) then the status code 200 is implied
    NSData *received = [self GET:@"http://www.google.ch" error:NULL];
    XCTAssertEqualObjects(received, [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding], @"Wrong data was returned");
}


#pragma mark - Test Network Call Verification

- (void)testYouCanVerifyNetworkCalls {
    // start monitoring for network activity
    [Network startObservingNetworkCalls];
    
    // you call some network
    [self GET:@"http://www.google.ch" error:NULL];
    
    // then you can verify
    verify Network.GET(@"http://www.google.ch");
    
    // uncalled URLs fail the verification
    ThisWillFail({
        verify Network.GET(@"http://you.did-not-call.me");
    });
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
