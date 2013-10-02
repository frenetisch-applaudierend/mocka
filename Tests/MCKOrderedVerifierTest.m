//
//  MCKOrderedVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKOrderedVerifier.h"

#import "TestExceptionUtils.h"
#import "FakeVerificationHandler.h"
#import "MCKExceptionFailureHandler.h"
#import "NSInvocation+TestSupport.h"


@interface MCKOrderedVerifierTest : XCTestCase @end
@implementation MCKOrderedVerifierTest {
    MCKOrderedVerifier *verifier;
    MCKInvocationPrototype *prototype;
}


#pragma mark - Setup

- (void)setUp {
    verifier = [[MCKOrderedVerifier alloc] init];
    verifier.failureHandler = [[MCKExceptionFailureHandler alloc] init];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation];
}


#pragma mark - Test Invocation Verification

- (void)testThatVerifyInvocationUsesVerificationHandler {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    verifier.verificationHandler = handler;
    
    // when
    [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    
    // then
    XCTAssertEqual([handler.calls count], (NSUInteger)1, @"Number of calls is wrong");
}

- (void)testThatVerifyInvocationFailsIfHandlerIsNotSatisfied {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
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
    
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:matching];
    
    // when
    [verifier verifyPrototype:prototype invocations:recordedInvocations];
    
    // then
    XCTAssertEqual([recordedInvocations count], (NSUInteger)1, @"Calls were not removed");
    XCTAssertEqual([[recordedInvocations lastObject] selector], @selector(tearDown), @"Wrong calls were removed");
}

- (void)testThatVerifyInvocationIgnoresSkippedInvocations {
    // given
    NSMutableArray *recordedInvocations = [NSMutableArray array];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(init)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(copy)]];
    
    NSMutableIndexSet *matching = [NSMutableIndexSet indexSet];
    [matching addIndex:0];
    [matching addIndex:2];
    
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:matching];
    
    
    // when
    verifier.skippedInvocations = 2;
    [verifier verifyPrototype:prototype invocations:recordedInvocations];
    
    // then
    XCTAssertEqual([recordedInvocations count], (NSUInteger)3, @"Calls were not removed");
    XCTAssertEqual([[recordedInvocations objectAtIndex:0] selector], @selector(setUp), @"Wrong calls were removed");
    XCTAssertEqual([[recordedInvocations objectAtIndex:1] selector], @selector(tearDown), @"Wrong calls were removed");
    XCTAssertEqual([[recordedInvocations objectAtIndex:2] selector], @selector(init), @"Wrong calls were removed");
}

- (void)testThatSkippedInvocationCountIsLastMatchedInvocationPosition {
    // given
    NSMutableArray *recordedInvocations = [NSMutableArray array];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(init)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(copy)]];
    [recordedInvocations addObject:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(mutableCopy)]];
    
    NSMutableIndexSet *matching = [NSMutableIndexSet indexSet];
    [matching addIndex:1];
    [matching addIndex:3];
    
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:matching];
    verifier.skippedInvocations = 1;
    
    // when
    [verifier verifyPrototype:prototype invocations:recordedInvocations];
    
    // then
    XCTAssertEqual(verifier.skippedInvocations, (NSUInteger)3, @"Skipped invocations count was not recorded");
}


#pragma mark - Test Return Value

- (void)testThatVerifyInvocationReturnsVerificationModeForSatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    MCKContextMode newMode = [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    XCTAssertEqual(newMode, MCKContextModeVerifying, @"Wrong context mode returned");
}

- (void)testThatVerifyInvocationReturnsVerificationModeForUnsatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    verifier.failureHandler = nil; // needed to prevent exception
    MCKContextMode newMode = [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    XCTAssertEqual(newMode, MCKContextModeVerifying, @"Wrong context mode returned");
}


#pragma mark - Test Error Reporting

- (void)testThatContextFailsWithCorrectErrorMessageForFailedVerify {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:@"Foo was never called"];
    
    // then
    AssertFailsWith(@"verify: Foo was never called", nil, 0, {
        [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    });
}

- (void)testThatContextFailsWithDefaultErrorMessageForVerifyIfTheHandlerDoesNotProvideOne {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
    // then
    AssertFailsWith(@"verify: failed with an unknown reason", nil, 0, {
        [verifier verifyPrototype:prototype invocations:[NSMutableArray array]];
    });
}

@end
