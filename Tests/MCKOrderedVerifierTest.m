//
//  MCKOrderedVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKOrderedVerifier.h"
#import "MCKInvocationCollection.h"
#import "MCKArgumentMatcherCollection.h"

#import "TestExceptionUtils.h"
#import "FakeVerificationHandler.h"
#import "MCKExceptionFailureHandler.h"
#import "NSInvocation+TestSupport.h"


@interface MCKOrderedVerifierTest : SenTestCase
@end

@implementation MCKOrderedVerifierTest {
    MCKOrderedVerifier *verifier;
}


#pragma mark - Setup

- (void)setUp {
    verifier = [[MCKOrderedVerifier alloc] init];
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

- (void)testThatVerifyInvocationIgnoresSkippedInvocations {
    // given
    MCKMutableInvocationCollection *recordedInvocations = [[MCKMutableInvocationCollection alloc] init];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(init)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(copy)]];
    
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
    [toRemove addIndex:0];
    [toRemove addIndex:2];
    
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:toRemove isSatisfied:YES];
    
    
    // when
    verifier.skippedInvocations = 2;
    [verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:recordedInvocations]; // any invocation is ok, just as long as the handler is called
    
    // then
    STAssertEquals([recordedInvocations.allInvocations count], (NSUInteger)3, @"Calls were not removed");
    STAssertEquals([[recordedInvocations.allInvocations objectAtIndex:0] selector], @selector(setUp), @"Wrong calls were removed");
    STAssertEquals([[recordedInvocations.allInvocations objectAtIndex:1] selector], @selector(tearDown), @"Wrong calls were removed");
    STAssertEquals([[recordedInvocations.allInvocations objectAtIndex:2] selector], @selector(init), @"Wrong calls were removed");
}

- (void)testThatSkippedInvocationCountIsLastMatchedInvocationPosition {
    // given
    MCKMutableInvocationCollection *recordedInvocations = [[MCKMutableInvocationCollection alloc] init];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(init)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(copy)]];
    [recordedInvocations addInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(mutableCopy)]];
    
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
    [toRemove addIndex:1];
    [toRemove addIndex:3];
    
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:toRemove isSatisfied:YES];
    verifier.skippedInvocations = 1;
    
    // when
    [verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:recordedInvocations]; // any invocation is ok, just as long as the handler is called
    
    // then
    STAssertEquals(verifier.skippedInvocations, (NSUInteger)3, @"Skipped invocations count was not recorded");
}


#pragma mark - Test Return Value

- (void)testThatVerifyInvocationReturnsVerificationModeForSatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    STAssertEquals([verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:nil], MCKContextModeVerifying, @"Wrong context mode returned");
}

- (void)testThatVerifyInvocationReturnsVerificationModeForUnsatisfiedHandler {
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    verifier.failureHandler = nil; // needed to prevent exception
    STAssertEquals([verifier verifyInvocation:nil withMatchers:nil inRecordedInvocations:nil], MCKContextModeVerifying, @"Wrong context mode returned");
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
