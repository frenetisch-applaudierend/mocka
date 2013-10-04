//
//  MCKInOrderCollectorTest.m
//  mocka
//
//  Created by Markus Gasser on 1.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Mocka/MCKInOrderCollector.h>
#import "NSInvocation+TestSupport.h"


@interface MCKInOrderCollectorTest : XCTestCase @end
@implementation MCKInOrderCollectorTest {
    MCKInOrderCollector *collector;
    NSMutableArray *invocations;
}

#pragma mark - Setup

- (void)setUp {
    collector = [[MCKInOrderCollector alloc] init];
    invocations = [NSMutableArray arrayWithObjects:
                   [NSInvocation voidMethodInvocationForTarget:nil],
                   [NSInvocation voidMethodInvocationForTarget:nil],
                   [NSInvocation voidMethodInvocationForTarget:nil], nil];
}


#pragma mark - Test Collecting

- (void)testThatCollectingResultReturnsCollectedResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:nil];
    
    // when
    MCKVerificationResult *collectedResult = [collector collectVerificationResult:result forInvocations:invocations];
    
    // then
    XCTAssertEqualObjects(collectedResult, result, @"Wrong result returned");
}

- (void)testThatCollectingResultRemovesNoInvocationsWhenNoMatchesForSuccessfulResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    // when
    [collector collectVerificationResult:result forInvocations:invocations];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Wrong invocations removed");
}

- (void)testThatCollectingResultRemovesAllInvocationsUpToLastMatchForSuccessfulResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ invocations[2] ];
    
    // when
    [collector collectVerificationResult:result forInvocations:invocations];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Wrong invocations removed");
}

- (void)testThatCollectingResultRemovesNoInvocationsWhenNoMatchesForFailureResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSet]];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    // when
    [collector collectVerificationResult:result forInvocations:invocations];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Wrong invocations removed");
}

- (void)testThatCollectingResultRemovesAllInvocationsUpToLastMatchForFailureResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ invocations[2] ];
    
    // when
    [collector collectVerificationResult:result forInvocations:invocations];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Wrong invocations removed");
}

- (void)testThatCollectingResultRemovesAllInvocationsForAllMatches {
    // given
    NSIndexSet *matching = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:matching];
    NSArray *expectedRemainingInvocations = @[];
    
    // when
    [collector collectVerificationResult:result forInvocations:invocations];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Wrong invocations removed");
}


#pragma mark - Test Processing

- (void)testThatProcessResultReturnsNil {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:nil];
    [collector collectVerificationResult:result forInvocations:invocations];
    
    // when
    MCKVerificationResult *collectedResult = [collector processCollectedResultsWithInvocations:invocations];
    
    // then
    XCTAssertNil(collectedResult, @"Should not have returned a result");
}

- (void)testThatProcessAddsSkippedVerifications {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ invocations[0], invocations[2] ];
    
    [collector collectVerificationResult:result forInvocations:invocations]; // removes invocation 0 and 1, 0 was not matched
    
    // when
    [collector processCollectedResultsWithInvocations:invocations]; // umatched but removed invocations (skipped) must be added
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Skipped invocations not added");
}

@end
