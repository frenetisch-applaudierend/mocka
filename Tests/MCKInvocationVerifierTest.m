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
#import "MCKVerificationResultCollector.h"


@interface MCKInvocationVerifier (TestSupport)

- (void)pushVerificationGroup:(MCKVerificationGroup *)verificationGroup;

@end


@interface MCKInvocationVerifierTest : XCTestCase @end
@implementation MCKInvocationVerifierTest {
    MCKInvocationVerifier *verifier;
    MCKMockingContext *context;
}

#pragma mark - Setup

- (void)setUp
{
    context = [[MCKMockingContext alloc] init];
    
    verifier = [[MCKInvocationVerifier alloc] initWithMockingContext:context];
    context.invocationVerifier = verifier;
    
    context.invocationRecorder = MKTMock([MCKInvocationRecorder class]);
    context.invocationStubber = MKTMock([MCKInvocationStubber class]);
    context.failureHandler = MKTMockProtocol(@protocol(MCKFailureHandler));
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
    
    [MKTVerify(context.failureHandler) handleFailureAtLocation:HC_anything() withReason:@"foo"];
}

- (void)testThatProcessVerificationSucceedsIfVerificationSucceedsInTopLevel
{
    MCKVerification *verification = MKTMock([MCKVerification class]);
    [MKTGiven([verification execute]) willReturn:[MCKVerificationResult successWithMatchingIndexes:nil]];
    
    [verifier processVerification:verification];
    
    [MKTVerifyCount(context.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
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
    
    [MKTVerify(context.invocationRecorder) removeInvocationsAtIndexes:result.matchingIndexes];
}


#pragma mark - Test Processing Top Level Verification Group

- (void)testThatProcessVerificationGroupExecutesVerificationGroupInTopLevel
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(verificationGroup) executeWithInvocationRecorder:context.invocationRecorder];
}

- (void)testThatProcessVerificationGroupFailsIfVerificationGroupFailsInTopLevel
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    [MKTGiven([verificationGroup executeWithInvocationRecorder:HC_anything()])
     willReturn:[MCKVerificationResult failureWithReason:@"foo" matchingIndexes:nil]];
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(context.failureHandler) handleFailureAtLocation:HC_anything() withReason:@"foo"];
}

- (void)testThatProcessVerificationGroupSucceedsIfVerificationGroupSucceedsInTopLevel
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    [MKTGiven([verificationGroup executeWithInvocationRecorder:HC_anything()])
     willReturn:[MCKVerificationResult successWithMatchingIndexes:nil]];
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerifyCount(context.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
}

KNMParametersFor(testThatMatchingInvocationsAreRemovedIfVerificationGroupFailsForResult, @[
    [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:10]],
    [MCKVerificationResult failureWithReason:@"foo" matchingIndexes:[NSIndexSet indexSetWithIndex:20]]
])
- (void)testThatMatchingInvocationsAreRemovedIfVerificationGroupFailsForResult:(MCKVerificationResult *)result
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    [MKTGiven([verificationGroup executeWithInvocationRecorder:HC_anything()])
     willReturn:result];
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(context.invocationRecorder) removeInvocationsAtIndexes:result.matchingIndexes];
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
    [MKTVerifyCount(context.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
}


#pragma mark - Test Processing Nested Verification Group

- (void)testThatProcessVerificationGroupExecutesVerificationGroupWhenNested
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    [verifier pushVerificationGroup:MKTMock([MCKVerificationGroup class])];
    
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(verificationGroup) executeWithInvocationRecorder:context.invocationRecorder];
}

- (void)testThatProcessVerificationGroupPassesResultToParentGroupWhenNested
{
    MCKVerificationGroup *verificationGroup = MKTMock([MCKVerificationGroup class]);
    MCKVerificationGroup *parentGroup = MKTMock([MCKVerificationGroup class]);
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:@"foo" matchingIndexes:nil];
    
    [MKTGiven([verificationGroup executeWithInvocationRecorder:HC_anything()]) willReturn:result];
    [MKTGiven([parentGroup collectResult:HC_anything()]) willReturn:[MCKVerificationResult successWithMatchingIndexes:nil]];
    
    
    [verifier pushVerificationGroup:parentGroup];
    [verifier processVerificationGroup:verificationGroup];
    
    [MKTVerify(parentGroup) collectResult:result];
    [MKTVerifyCount(context.failureHandler, MKTNever()) handleFailureAtLocation:HC_anything() withReason:HC_anything()];
}

@end
