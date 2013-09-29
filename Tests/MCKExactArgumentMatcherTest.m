//
//  MCKExactArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKExactArgumentMatcher.h"


@interface MCKExactArgumentMatcherTest : XCTestCase
@end

@implementation MCKExactArgumentMatcherTest {
    MCKExactArgumentMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    matcher = [[MCKExactArgumentMatcher alloc] init];
}


#pragma mark - Test Cases

- (void)testThatMatcherMatchesExactArgumentGiven {
    // given
    matcher.expectedArgument = @2000;
    
    // when
    BOOL result = [matcher matchesCandidate:[NSNumber numberWithInt:2000]];
    
    // then
    XCTAssertTrue(result, @"Matcher should have matched");
}

- (void)testThatMatcherDoesNotMatchArgumentWhichIsNotExpected {
    // given
    matcher.expectedArgument = @2000;
    
    // when
    BOOL result = [matcher matchesCandidate:[NSNumber numberWithInt:1000]];
    
    // then
    XCTAssertFalse(result, @"Matcher should not have matched");
}

@end
