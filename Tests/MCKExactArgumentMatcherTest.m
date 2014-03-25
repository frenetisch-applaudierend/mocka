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


#pragma mark - Test General Cases

- (void)testThatMatcherMatchesExactArgumentGiven {
    matcher.expectedArgument = @2000;
    
    expect([matcher matchesCandidate:[NSNumber numberWithInt:2000]]).to.beTruthy();
}

- (void)testThatMatcherDoesNotMatchArgumentWhichIsNotExpected {
    // given
    matcher.expectedArgument = @2000;
    
    expect([matcher matchesCandidate:[NSNumber numberWithInt:1000]]).to.beFalsy();
}

@end
