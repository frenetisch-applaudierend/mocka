//
//  MCKNetworkMockTest.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKNetworkMock.h"
#import "MCKNetworkMock_Private.h"
#import "MCKNetworkRequestMatcher.h"
#import "NSInvocation+MCKArgumentHandling.h"

#import "FakeMockingContext.h"
#import "NSInvocation+TestSupport.h"


@interface MCKNetworkMockTest : XCTestCase @end
@implementation MCKNetworkMockTest {
    MCKNetworkMock *networkMock;
    FakeMockingContext *mockingContext;
}

#pragma mark - Setup

- (void)setUp {
    [OHHTTPStubs removeAllStubs];
    
    mockingContext = [FakeMockingContext fakeContext];
    networkMock = [[MCKNetworkMock alloc] init];
    networkMock.mockingContext = mockingContext;
}

- (void)tearDown {
    networkMock = nil;
    mockingContext = nil;
}


#pragma mark - Test GET() Calls

- (void)testThatGETReturnsRequestMatcher {
    XCTAssertTrue([networkMock.GET(@"http://www.google.ch") isKindOfClass:[MCKNetworkRequestMatcher class]],
                  @"Did not return a request matcher");
}

- (void)testThatGETSetsMethodOnMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET([NSURL URLWithString:@"http://www.google.ch"]);
    
    // then
    XCTAssertEqualObjects(matcher.HTTPMethod, @"GET", @"Wrong URL passed to matcher");
}

- (void)testThatGETWithURLSetsURLOnMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET([NSURL URLWithString:@"http://www.google.ch"]);
    
    // then
    XCTAssertEqualObjects(matcher.URL, [NSURL URLWithString:@"http://www.google.ch"], @"Wrong URL passed to matcher");
}

- (void)testThatGETWithStringSetsURLOnMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET(@"http://www.google.ch");
    
    // then
    XCTAssertEqualObjects(matcher.URL, [NSURL URLWithString:@"http://www.google.ch"], @"Wrong URL passed to matcher");
}

- (void)testThatGETRegistersCallOnContextWithMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET(@"http://www.google.ch");
    
    // then
    XCTAssertTrue([mockingContext.handledInvocations count] == 1, @"Wrong invocation count");
    
    NSInvocation *invocation = mockingContext.handledInvocations[0];
    XCTAssertEqualObjects(invocation.target, networkMock, @"Wrong invocation target");
    XCTAssertEqual(invocation.selector, @selector(handleNetworkRequest:), @"Wrong invocation selector");
    XCTAssertEqualObjects([invocation objectParameterAtIndex:0], matcher, @"Wrong invocation argument");
}

@end
