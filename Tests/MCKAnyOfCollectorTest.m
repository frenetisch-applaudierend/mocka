//
//  MCKAnyOfCollectorTest.m
//  mocka
//
//  Created by Markus Gasser on 29.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKAnyOfCollector.h"


@interface MCKAnyOfCollectorTest : XCTestCase @end
@implementation MCKAnyOfCollectorTest {
    MCKAnyOfCollector *collector;
    MCKInvocationRecorder *invocationRecorder;
}

#pragma mark - Setup

- (void)setUp
{
    collector = [[MCKAnyOfCollector alloc] init];
    invocationRecorder = [[MCKInvocationRecorder alloc] initWithMockingContext:nil];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:@"a"]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:@"b"]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:@"c"]];
}


#pragma mark - Test Collecting

- (void)testThatCollectingSuccessfulResultReturnsCollectedResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:nil];
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    
    // when
    MCKVerificationResult *collectedResult = [collector collectVerificationResult:result];
    
    // then
    expect(collectedResult).to.equal(result);
}

- (void)testThatCollectingFailureResultReturnsSuccessfulResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:nil];
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    
    // when
    MCKVerificationResult *collectedResult = [collector collectVerificationResult:result];
    
    // then
    expect(collectedResult).to.equal([MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]]);
}

- (void)testThatCollectingResultDoesRemoveMatchingInvocationsForSuccessfulResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:2]];
    NSArray *expectedRemainingInvocations = [invocationRecorder.recordedInvocations subarrayWithRange:NSMakeRange(0, 2)];
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatCollectingResultDoesNotRemoveAnyInvocationsForFailureResult
{
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSetWithIndex:2]];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // when
    [collector beginCollectingResultsWithInvocationRecorder:invocationRecorder];
    [collector collectVerificationResult:result];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

@end
