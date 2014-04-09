//
//  MCKNetworkRequestMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKNetworkRequestMatcher.h"
#import "MCKValueSerialization.h"


#define URL(url) [NSURL URLWithString:(url)]


@interface MCKNetworkRequestMatcherTest : XCTestCase @end
@implementation MCKNetworkRequestMatcherTest

#pragma mark - Test Basic Configuration

- (void)testThatMatcherSucceedsForSameURLAndMethod {
    // given
    MCKNetworkRequestMatcher *matcher = [MCKNetworkRequestMatcher matcherForURL:URL(@"http://www.google.ch") HTTPMethod:@"PUT"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL(@"http://www.google.ch")];
    request.HTTPMethod = @"PUT";
    
    // then
    XCTAssertTrue([matcher matchesCandidate:MCKSerializeValue(request)], @"Should match candidate");
}

- (void)testThatMatcherFailsForDifferentURL {
    // given
    MCKNetworkRequestMatcher *matcher = [MCKNetworkRequestMatcher matcherForURL:URL(@"http://www.google.ch") HTTPMethod:@"GET"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL(@"http://www.wrong-host.com")];
    request.HTTPMethod = @"GET";
    
    // then
    XCTAssertFalse([matcher matchesCandidate:MCKSerializeValue(request)], @"Should not match candidate");
}

- (void)testThatMatcherFailsForDifferentMethod {
    // given
    MCKNetworkRequestMatcher *matcher = [MCKNetworkRequestMatcher matcherForURL:URL(@"http://www.google.ch") HTTPMethod:@"GET"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL(@"http://www.google.ch")];
    request.HTTPMethod = @"PUT";
    
    // then
    XCTAssertFalse([matcher matchesCandidate:MCKSerializeValue(request)], @"Should not match candidate");
}

@end
