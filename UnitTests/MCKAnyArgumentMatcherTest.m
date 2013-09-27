//
//  MCKAnyArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKAnyArgumentMatcher.h"


@interface MCKAnyArgumentMatcherTest : SenTestCase
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
    STAssertTrue([matcher matchesCandidate:nil], @"Nil was not matched");
}

- (void)testThatNonNilCandidateMatches {
    STAssertTrue([matcher matchesCandidate:@"Foobar"], @"Non-nil candidate was not matched");
}

@end
