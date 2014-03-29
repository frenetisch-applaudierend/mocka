//
//  MCKInOrderCollectorTest.m
//  mocka
//
//  Created by Markus Gasser on 1.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKInOrderCollector.h"
#import "NSInvocation+TestSupport.h"


@interface MCKInOrderCollectorTest : XCTestCase @end
@implementation MCKInOrderCollectorTest {
    MCKInOrderCollector *collector;
    MCKInvocationRecorder *invocationRecorder;
}

#pragma mark - Setup

- (void)setUp
{
    collector = [[MCKInOrderCollector alloc] init];
    invocationRecorder = [[MCKInvocationRecorder alloc] initWithMockingContext:nil];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
}


#pragma mark - Test Collecting

- (void)testThatCollectingResultReturnsCollectedResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:nil];
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    
    // when
    MCKVerificationResult *collectedResult = [collector collectVerificationResult:result];
    
    // then
    expect(collectedResult).to.equal(result);
}

- (void)testThatCollectingResultDoesNotRemoveAnyInvocationsWhenNoMatchesForSuccessfulResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultRemovesAllInvocationsUpToLastMatchForSuccessfulResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ [invocationRecorder invocationAtIndex:2] ];
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultDoesNotRemoveAnyInvocationsWhenNoMatchesForFailureResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSet]];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultRemovesAllInvocationsUpToLastMatchForFailureResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ [invocationRecorder invocationAtIndex:2] ];
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultRemovesAllInvocationsForAllMatches {
    // given
    NSIndexSet *matching = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:matching];
    NSArray *expectedRemainingInvocations = @[];
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}


#pragma mark - Test Processing

- (void)testThatProcessResultReturnsNil {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:nil];
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // when
    MCKVerificationResult *collectedResult = [collector finishCollectingResults];
    
    // then
    expect(collectedResult).to.beNil();
}

- (void)testThatProcessAddsSkippedVerifications {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[
        [invocationRecorder invocationAtIndex:0], [invocationRecorder invocationAtIndex:2]
    ];
    
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result]; // removes invocation 0 and 1, 0 was not matched
    
    // when
    [collector finishCollectingResults]; // umatched but removed invocations (skipped) must be added
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

@end
