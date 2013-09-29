//
//  MCKDefaultVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKDefaultVerifier.h"
#import "MCKArgumentMatcherCollection.h"

#import "TestExceptionUtils.h"
#import "FakeVerificationHandler.h"
#import "MCKExceptionFailureHandler.h"
#import "NSInvocation+TestSupport.h"


@interface MCKDefaultVerifierTest : XCTestCase
@end

@implementation MCKDefaultVerifierTest {
    MCKDefaultVerifier *verifier;
    MCKInvocationPrototype *prototype;
}


#pragma mark - Setup

- (void)setUp {
    verifier = [[MCKDefaultVerifier alloc] init];
    verifier.failureHandler = [[MCKExceptionFailureHandler alloc] init];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation];
}


#pragma mark - Test Invocation Verification

- (void)testThatVerifyInvocationUsesVerificationHandler {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    
    // when
    [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    
    // then
    XCTAssertEqual([(FakeVerificationHandler *)verifier.verificationHandler numberOfCalls], (NSUInteger)1,
                   @"Number of calls is wrong");
}

- (void)testThatVerifyInvocationFailsIfHandlerIsNotSatisfied {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    
    // then
    AssertFails({
        [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    });
}

- (void)testThatVerifyInvocationRemovesMatchingInvocationsFromRecordedInvocations {
    // given
    NSMutableArray *recordedInvocations = [NSMutableArray array];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]];
    
    NSMutableIndexSet *matching = [NSMutableIndexSet indexSet];
    [matching addIndex:0];
    [matching addIndex:2];
    
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:matching isSatisfied:YES];
    
    // when
    [verifier verifyPrototype:prototype invocations:recordedInvocations];
    
    // then
    XCTAssertEqual([recordedInvocations count], (NSUInteger)1, @"Calls were not removed");
    XCTAssertEqual([[recordedInvocations lastObject] selector], @selector(tearDown), @"Wrong calls were removed");
}


#pragma mark - Test Return Value

- (void)testThatVerifyInvocationReturnsRecordingModeForSatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    MCKContextMode newMode = [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    XCTAssertEqual(newMode, MCKContextModeRecording, @"Wrong context mode returned");
}

- (void)testThatVerifyInvocationReturnsRecordingModeForUnsatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    verifier.failureHandler = nil; // needed to prevent exception
    MCKContextMode newMode = [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    XCTAssertEqual(newMode, MCKContextModeRecording, @"Wrong context mode returned");
}


#pragma mark - Test Error Reporting

- (void)testThatContextFailsWithCorrectErrorMessageForFailedVerify {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:@"Foo was never called"];
    
    // then
    AssertFailsWith(@"verify: Foo was never called", nil, 0, {
        [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    });
}

- (void)testThatContextFailsWithDefaultErrorMessageForVerifyIfTheHandlerDoesNotProvideOne {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:nil];
    
    // then
    AssertFailsWith(@"verify: failed with an unknown reason", nil, 0, {
        [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    });
}

@end
