//
//  MCKInvocationVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKInvocationVerifier.h"

#import "MCKMockingContext.h"
#import "MCKInvocationRecorder.h"
#import "MCKInvocationStubber.h"

#import "MCKVerification.h"
#import "MCKVerificationGroup.h"
#import "MCKVerificationHandler.h"


@interface MCKInvocationVerifier (TestSupport)

- (void)pushVerificationGroup:(MCKVerificationGroup *)verificationGroup;

@end


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


#pragma mark - Test Processing Top Level Verification

- (void)testThatProcessVerificationExecutesVerificationInTopLevel
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    
    [verifier processVerification:verification];
    
    [MKTVerify(verification) execute];
}

- (void)testThatProcessVerificationFailsIfVerificationFailsInTopLevel
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    [MKTGiven([verification execute]) willReturn:[MCKVerificationResult failureWithReason:@"foo" matchingIndexes:nil]];
    
    [verifier processVerification:verification];
    
    [MKTVerify(mockingContext.failureHandler) handleFailureAtLocation:HC_anything() withReason:@"foo"];
}

- (void)testThatProcessVerificationSucceedsIfVerificationSucceedsInTopLevel
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    [MKTGiven([verification execute]) willReturn:[MCKVerificationResult successWithMatchingIndexes:nil]];
    
    [verifier processVerification:verification];
    
    [MKTVerifyCount(mockingContext.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
}

KNMParametersFor(testThatMatchingInvocationsAreRemovedIfVerificationFailsForResult, @[
    [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:10]],
    [MCKVerificationResult failureWithReason:@"foo" matchingIndexes:[NSIndexSet indexSetWithIndex:20]]
])
- (void)testThatMatchingInvocationsAreRemovedIfVerificationFailsForResult:(MCKVerificationResult *)result
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    
    [MKTGiven([verification execute]) willReturn:result];
    
    [verifier processVerification:verification];
    
    [MKTVerify(mockingContext.invocationRecorder) removeInvocationsAtIndexes:result.matchingIndexes];
}


#pragma mark - Test Processing Top Level Verification Group

- (void)testThatProcessVerificationGroupExecutesVerificationGroupInTopLevel
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(verificationGroup) execute];
}


- (void)testThatProcessVerificationGroupFailsIfVerificationGroupFailsInTopLevel
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    [MKTGiven([verificationGroup execute]) willReturn:[MCKVerificationResult failureWithReason:@"foo" matchingIndexes:nil]];
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(mockingContext.failureHandler) handleFailureAtLocation:HC_anything() withReason:@"foo"];
}

- (void)testThatProcessVerificationGroupSucceedsIfVerificationGroupSucceedsInTopLevel
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    [MKTGiven([verificationGroup execute]) willReturn:[MCKVerificationResult successWithMatchingIndexes:nil]];
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerifyCount(mockingContext.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
}

KNMParametersFor(testThatMatchingInvocationsAreRemovedIfVerificationGroupFailsForResult, @[
    [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:10]],
    [MCKVerificationResult failureWithReason:@"foo" matchingIndexes:[NSIndexSet indexSetWithIndex:20]]
])
- (void)testThatMatchingInvocationsAreRemovedIfVerificationGroupFailsForResult:(MCKVerificationResult *)result
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    [MKTGiven([verificationGroup execute]) willReturn:result];
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(mockingContext.invocationRecorder) removeInvocationsAtIndexes:result.matchingIndexes];
}


#pragma mark - Test Processing Nested Verification

- (void)testThatProcessVerificationExecutesVerificationWhenNested
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    [verifier pushVerificationGroup:MKTMock([MCKVerificationGroup class])];
    
    [verifier processVerification:verification];
    
    [MKTVerify(verification) execute];
}

- (void)testThatProcessVerificationPassesResultToGroupWhenNested
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:@"foo" matchingIndexes:nil];
    
    [MKTGiven([verification execute]) willReturn:result];
    [MKTGiven([verificationGroup collectResult:HC_anything()]) willReturn:[MCKVerificationResult successWithMatchingIndexes:nil]];
    
    
    [verifier pushVerificationGroup:verificationGroup];
    [verifier processVerification:verification];
    
    [MKTVerify(verificationGroup) collectResult:result];
    [MKTVerifyCount(mockingContext.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
}

@end
