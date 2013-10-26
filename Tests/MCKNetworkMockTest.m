//
//  MCKNetworkMockTest.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKNetworkMock.h"
#import "MCKNetworkRequestMatcher.h"


@interface MCKNetworkMockTest : XCTestCase @end
@implementation MCKNetworkMockTest {
    MCKNetworkMock *networkMock;
}

#pragma mark - Setup

- (void)setUp {
    networkMock = [[MCKNetworkMock alloc] init];
}


#pragma mark - Test GET() Calls

- (void)testThatGETReturnsRequestMatcher {
    XCTAssertTrue([networkMock.GET(@"http://www.google.ch") isKindOfClass:[MCKNetworkRequestMatcher class]],
                  @"Did not return a request matcher");
}

- (void)testThatGETWithURLSetsURLOnMatcher {
    // given
    NSURL *url = [NSURL URLWithString:@"http://www.google.ch"];
    
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET(url);
    
    // then
    XCTAssertEqualObjects(matcher.URL, url, @"Wrong URL passed to matcher");
}

- (void)testThatGETWithURLSetsMethodOnMatcher {
    // when
    MCKNetworkRequestMatcher *matcher = networkMock.GET([NSURL URLWithString:@"http://www.google.ch"]);
    
    // then
    XCTAssertEqualObjects(matcher.HTTPMethod, @"GET", @"Wrong URL passed to matcher");
}

@end
