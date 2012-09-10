//
//  RGMockAnyArgumentMatcherTest.m
//  rgmock
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockAnyArgumentMatcher.h"


@interface RGMockAnyArgumentMatcherTest : SenTestCase
@end

@implementation RGMockAnyArgumentMatcherTest {
    RGMockAnyArgumentMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    matcher = [[RGMockAnyArgumentMatcher alloc] init];
}


#pragma mark - Test Cases

- (void)testThatNilCandidateMatches {
    STAssertTrue([matcher matchesCandidate:nil], @"Nil was not matched");
}

- (void)testThatNonNilCandidateMatches {
    STAssertTrue([matcher matchesCandidate:@"Foobar"], @"Non-nil candidate was not matched");
}

@end
