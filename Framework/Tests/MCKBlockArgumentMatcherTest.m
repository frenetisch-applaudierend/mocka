//
//  MCKBlockArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKBlockArgumentMatcher.h"


@interface MCKBlockArgumentMatcherTest : XCTestCase
@end

@implementation MCKBlockArgumentMatcherTest {
    MCKBlockArgumentMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    matcher = [[MCKBlockArgumentMatcher alloc] init];
}


#pragma mark - Test Cases

- (void)testThatCandidateIsPassedToMatcherBlock {
    // given
    __block id passedCandiate = nil;
    matcher.matcherBlock = ^BOOL(id candidate) {
        passedCandiate = candidate;
        return YES;
    };
    
    // when
    [matcher matchesCandidate:@"Hello World"];
    
    // then
    XCTAssertEqualObjects(passedCandiate, @"Hello World", @"Wrong candidate passed");
}

- (void)testThatMatcherReturnsTrueIfNoMatcherBlockIsSet {
    // given
    matcher.matcherBlock = nil;
    
    // then
    XCTAssertTrue([matcher matchesCandidate:@"Foo"], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsTrueIfMatcherBlockReturnsTrue {
    // given
    matcher.matcherBlock = ^(id _) { return YES; };
    
    // then
    XCTAssertTrue([matcher matchesCandidate:@"Foo"], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsFalseIfMatcherBlockReturnsFalse {
    // given
    matcher.matcherBlock = ^(id _) { return NO; };
    
    // then
    XCTAssertFalse([matcher matchesCandidate:@"Foo"], @"Matcher should not have matched");
}

@end
