//
//  MCKAnyArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKAnyArgumentMatcher.h"


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
    XCTAssertTrue([matcher matchesCandidate:nil], @"Nil was not matched");
}

- (void)testThatNonNilCandidateMatches {
    XCTAssertTrue([matcher matchesCandidate:@"Foobar"], @"Non-nil candidate was not matched");
}

@end
