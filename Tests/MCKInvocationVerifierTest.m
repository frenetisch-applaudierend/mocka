//
//  MCKInvocationVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKInvocationVerifier.h"
#import "MCKVerification.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"

#import "TestingSupport.h"


@interface MCKInvocationVerifierTest : XCTestCase @end
@implementation MCKInvocationVerifierTest {
    MCKInvocationVerifier *verifier;
    MCKMockingContext *mockingContext;
}

#pragma mark - Setup

- (void)setUp
{
    mockingContext = [[MCKMockingContext alloc] init];
    
    verifier = [[MCKInvocationVerifier alloc] initWithMockingContext:mockingContext];
    mockingContext.invocationVerifier = verifier;
    
    mockingContext.invocationRecorder = MKTMock([MCKInvocationRecorder class]);
    mockingContext.invocationStubber = MKTMock([MCKInvocationStubber class]);
    mockingContext.failureHandler = MKTMockProtocol(@protocol(MCKFailureHandler));
}


#pragma mark - Test Processing Single Verification

- (void)testThatProcessVerificationExecutesVerificationForSingleVerification
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    
    [verifier processVerification:verification];
    
    [MKTVerify(verification) execute];
}

- (void)testThatProcessVerificationFailsIfVerificationFailsForSingleVerification
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    [MKTGiven([verification execute]) willReturn:[MCKVerificationResult failureWithReason:@"foo" matchingIndexes:nil]];
    
    [verifier processVerification:verification];
    
    [MKTVerify(mockingContext.failureHandler) handleFailureAtLocation:HC_anything() withReason:@"foo"];
}

- (void)testThatProcessVerificationSucceedsIfVerificationSucceedsForSingleVerification
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    [MKTGiven([verification execute]) willReturn:[MCKVerificationResult successWithMatchingIndexes:nil]];
    
    [verifier processVerification:verification];
    
    [MKTVerifyCount(mockingContext.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
}

- (void)testThatMatchingInvocationsAreRemovedIfVerificationSucceedsForSingleVerification
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:10];
    [MKTGiven([verification execute]) willReturn:[MCKVerificationResult successWithMatchingIndexes:indexes]];
    
    [verifier processVerification:verification];
    
    [MKTVerify(mockingContext.invocationRecorder) removeInvocationsAtIndexes:indexes];
}

@end
