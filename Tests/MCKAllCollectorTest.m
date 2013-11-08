//
//  MCKAllCollectorTest.m
//  mocka
//
//  Created by Markus Gasser on 8.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "TestingSupport.h"
#import "MCKAllCollector.h"
#import "NSInvocation+TestSupport.h"


@interface MCKAllCollectorTest : XCTestCase @end
@implementation MCKAllCollectorTest {
    MCKAllCollector *collector;
    MCKInvocationRecorder *invocationRecorder;
}

#pragma mark - Setup

- (void)setUp {
    collector = [[MCKAllCollector alloc] init];
    invocationRecorder = [[MCKInvocationRecorder alloc] initWithMockingContext:nil];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
}


#pragma mark - Test Collecting

- (void)testThatCollectingResultReturnsCollectedResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:nil];
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    
    // when
    MCKVerificationResult *collectedResult = [collector collectVerificationResult:result];
    
    // then
    expect(collectedResult).to.equal(result);
}

- (void)testThatCollectingResultDoesNotRemoveAnyInvocationsWhenNoMatchesForSuccessfulResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultRemovesSuccessfulResult {
    // given
    NSIndexSet *matchingIndexes = [NSIndexSet indexSetWithIndex:1];
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:matchingIndexes];
    NSArray *expectedRemainingInvocations = @[
        [invocationRecorder invocationAtIndex:0],
        [invocationRecorder invocationAtIndex:2]
    ];
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultDoesNotRemoveAnyInvocationsWhenNoMatchesForFailureResult {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSet]];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultRemovesFailureResult {
    // given
    NSIndexSet *matchingIndexes = [NSIndexSet indexSetWithIndex:1];
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:matchingIndexes];
    NSArray *expectedRemainingInvocations = @[
        [invocationRecorder invocationAtIndex:0],
        [invocationRecorder invocationAtIndex:2]
    ];
    
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

@end
