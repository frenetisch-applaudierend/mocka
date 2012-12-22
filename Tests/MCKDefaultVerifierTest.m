//
//  MCKDefaultVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKDefaultVerifier.h"
#import "MCKInvocationCollection.h"
#import "MCKArgumentMatcherCollection.h"

#import "TestExceptionUtils.h"
#import "FakeVerificationHandler.h"
#import "MCKExceptionFailureHandler.h"
#import "NSInvocation+TestSupport.h"


@interface MCKDefaultVerifierTest : SenTestCase
@end

@implementation MCKDefaultVerifierTest {
    MCKDefaultVerifier *verifier;
}


#pragma mark - Setup

- (void)setUp {
    verifier = [[MCKDefaultVerifier alloc] init];
    verifier.failureHandler = [[MCKExceptionFailureHandler alloc] init];
}


#pragma mark - Test Invocation Verification

- (void)testThatVerifyInvocationUsesVerificationHandler {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    
    // when
    [verifier verifyInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)] withMatchers:nil inRecordedInvocations:nil];
    
    // then
    STAssertEquals([(FakeVerificationHandler *)verifier.verificationHandler numberOfCalls], (NSUInteger)1, @"Number of calls is wrong");
}

- (void)testThatVerifyInvocationFailsIfHandlerIsNotSatisfied {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    
    // then
    AssertFails({
        [verifier verifyInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)] withMatchers:nil inRecordedInvocations:nil];
    });
}

- (void)testThatVerifyInvocationRemovesMatchingInvocationsFromRecordedInvocations {
    // given
    MCKMutableInvocationCollection *recordedInvocations = [[MCKMutableInvocationCollection alloc] init];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]];
    
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
    [toRemove addIndex:0];
    [toRemove addIndex:2];
    
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:toRemove isSatisfied:YES];
    
    
    // when
    [verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:recordedInvocations]; // any invocation is ok, just as long as the handler is called
    
    // then
    STAssertEquals([recordedInvocations.allInvocations count], (NSUInteger)1, @"Calls were not removed");
    STAssertEquals([[recordedInvocations.allInvocations lastObject] selector], @selector(tearDown), @"Wrong calls were removed");
}


#pragma mark - Test Return Value

- (void)testThatVerifyInvocationReturnsRecordingModeForSatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    STAssertEquals([verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:nil], MCKContextModeRecording, @"Wrong context mode returned");
}

- (void)testThatVerifyInvocationReturnsRecordingModeForUnsatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    verifier.failureHandler = nil; // needed to prevent exception
    STAssertEquals([verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:nil], MCKContextModeRecording, @"Wrong context mode returned");
}


#pragma mark - Test Error Reporting

- (void)testThatContextFailsWithCorrectErrorMessageForFailedVerify {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:@"Foo was never called"];
    
    // then
    AssertFailsWith(@"verify: Foo was never called", nil, 0, {
        [verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:nil];
    });
}

- (void)testThatContextFailsWithDefaultErrorMessageForVerifyIfTheHandlerDoesNotProvideOne {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:nil];
    
    // then
    AssertFailsWith(@"verify: failed with an unknown reason", nil, 0, {
        [verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:nil];
    });
}

@end
