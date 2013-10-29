//
//  ExamplesNetworkMockingTest.m
//  mocka
//
//  Created by Markus Gasser on 25.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExamplesCommon.h"

#import "MCKMockingContext.h"


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
    
    // perform some network operation
    [self GET:@"http://www.google.ch" error:NULL];
    
    // then you can verify it
    verify Network.GET(@"http://www.google.ch");
    
    // uncalled URLs fail the verification
    ThisWillFail({
        verify Network.GET(@"http://you.did-not-call.me");
    });
}


#pragma mark - Test Disabling Network Access

- (void)testYouCanDisableAndEnableNetworkAccess {
    // disable the network
    [Network disable];
    
    // perform some network operation
    NSError *error = nil;
    NSData *data = [self GET:@"http://www.google.ch" error:&error];
    
    // the data returned is nil and the error is set to a "no network error"
    XCTAssertNil(data, @"Data should be nil");
    XCTAssertEqualObjects(error.domain, NSURLErrorDomain, @"Wrong error domain");
    XCTAssertEqual(error.code, (NSInteger)NSURLErrorNotConnectedToInternet, @"Wrong error code");
    
    // later you can re-enable the network
    [Network enable];
    
    // perform some network operation
    error = nil;
    data = [self GET:@"http://www.google.ch" error:&error];
    
    // the data returned is nil and the error is set to a "no network error"
    XCTAssertNotNil(data, @"Data should not be nil");
    XCTAssertNil(error, @"Error should be nil");
}

- (void)testStubbingAndVerificationAlsoWorkWhenAccessIsDisabled {
    // disable the network
    [Network disable];
    
    // set up a stub
    whenCalling Network.GET(@"http://www.google.ch") thenDo {
        returnValue([@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding]);
    };
    
    // if you now make a call to the specified URL you'll receive the stubbed return value
    // if you use returnValue(...) then the status code 200 is implied
    NSData *received = [self GET:@"http://www.google.ch" error:NULL];
    XCTAssertEqualObjects(received, [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding], @"Wrong data was returned");
    
    verify Network.GET(@"http://www.google.ch");
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
