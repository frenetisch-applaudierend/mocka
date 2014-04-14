//
//  MCKAnyArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKAnyArgumentMatcher.h"
#import "MCKValueSerialization.h"


@interface MCKAnyArgumentMatcherTest : XCTestCase
@end

@implementation MCKAnyArgumentMatcherTest {
    MCKAnyArgumentMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    matcher = [[MCKAnyArgumentMatcher alloc] init];
}


#pragma mark - Test Object Matching

- (void)testThatNilCandidateMatches {
    expect([matcher matchesCandidate:MCKSerializeValue(nil)]).to.beTruthy();
    expect([matcher matchesCandidate:nil]).to.beTruthy();
}

- (void)testThatNonNilCandidateMatches {
    expect([matcher matchesCandidate:MCKSerializeValue(@"Foobar")]).to.beTruthy();
}

@end
