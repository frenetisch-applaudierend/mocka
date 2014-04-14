//
//  MCKHamcrestArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKHamcrestArgumentMatcher.h"
#import "MCKValueSerialization.h"
#import "HCBlockMatcher.h"


@interface MCKHamcrestArgumentMatcherTest : XCTestCase @end
@implementation MCKHamcrestArgumentMatcherTest {
    MCKHamcrestArgumentMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp
{
    matcher = [[MCKHamcrestArgumentMatcher alloc] init];
}


#pragma mark - Test Cases

- (void)testThatMatcherCallsHamcrestMatcherWithPassedCandidate
{
    // given
    __block id passedCandidate = nil;
    matcher.hamcrestMatcher = [HCBlockMatcher matcherWithBlock:^BOOL(id candidate) {
        passedCandidate = candidate;
        return NO;
    }];
    
    // when
    [matcher matchesCandidate:MCKSerializeValue(@"Hello World")];
    
    // then
    expect(passedCandidate).to.equal(@"Hello World");
}

- (void)testThatMatcherReturnsTrueIfNoHamcrestMatcherIsSet
{
    // given
    matcher.hamcrestMatcher = nil;
    
    // then
    XCTAssertTrue([matcher matchesCandidate:MCKSerializeValue(@"Foo")], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsTrueIfHamcrestMatcherReturnsTrue
{
    // given
    matcher.hamcrestMatcher = [HCBlockMatcher matcherWithBlock:^(id _) { return YES; }];
    
    // then
    XCTAssertTrue([matcher matchesCandidate:MCKSerializeValue(@"Foo")], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsFalseIfHamcrestMatcherReturnsFalse {
    // given
    matcher.hamcrestMatcher = [HCBlockMatcher matcherWithBlock:^(id _) { return NO; }];
    
    // then
    XCTAssertFalse([matcher matchesCandidate:MCKSerializeValue(@"Foo")], @"Matcher should not have matched");
}

@end
