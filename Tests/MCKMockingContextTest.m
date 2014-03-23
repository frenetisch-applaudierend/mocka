//
//  MCKMockingContextTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>

#import "MCKMockingContext.h"

#import "MCKInvocationRecorder.h"
#import "MCKInvocationStubber.h"
#import "MCKInvocationVerifier.h"
#import "MCKFailureHandler.h"



#import "MCKStub.h"
#import "MCKBlockArgumentMatcher.h"

#import "MCKDefaultVerificationHandler.h"
#import "MCKArgumentMatcherRecorder.h"



@interface MCKMockingContextTest : XCTestCase @end
@implementation MCKMockingContextTest {
    MCKMockingContext *context;
}

#pragma mark - Setup

- (void)setUp
{
    context = [[MCKMockingContext alloc] initWithTestCase:self];
    context.invocationRecorder = MKTMock([MCKInvocationRecorder class]);
    context.invocationStubber = MKTMock([MCKInvocationStubber class]);
    context.invocationVerifier = MKTMock([MCKInvocationVerifier class]);
    context.argumentMatcherRecorder = MKTMock([MCKArgumentMatcherRecorder class]);
    context.failureHandler = MKTMock([MCKFailureHandler class]);
}


#pragma mark - Test Handling Invocations

- (void)testThatHandlingInvocationRetainsInvocationArguments
{
    // given
    NSInvocation *invocation = MKTMock([NSInvocation class]);
    
    // when
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(invocation) retainArguments];
}

- (void)testThatHandlingInvocationValidatesArgumentMatchers
{
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(context.argumentMatcherRecorder) validateForMethodSignature:invocation.methodSignature];
}

- (void)testThatHandlingInvocationClearsArgumentMatchers
{
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(context.argumentMatcherRecorder) collectAndReset];
}

- (void)testThatHandlingInvocationInRecordingModeDispatchesToInvocationRecorder {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation];
    
    // when
    [context updateContextMode:MCKContextModeRecording];
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(context.invocationRecorder) handleInvocationPrototype:prototype];
    
    [MKTVerifyCount(context.invocationStubber, MKTNever()) recordStubPrototype:HC_anything()];
    [MKTVerifyCount(context.invocationVerifier, MKTNever()) verifyInvocationsForPrototype:HC_anything()];
}

- (void)testThatHandlingInvocationInRecordingModeKeepsContextInRecordingMode {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context updateContextMode:MCKContextModeRecording];
    [context handleInvocation:invocation];
    
    // then
    expect(context.mode).to.equal(MCKContextModeRecording);
}

- (void)testThatHandlingInvocationInStubbingModeDispatchesToInvocationStubber {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation];
    
    // when
    [context updateContextMode:MCKContextModeStubbing];
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(context.invocationStubber) recordStubPrototype:prototype];
    
    [MKTVerifyCount(context.invocationRecorder, MKTNever()) handleInvocationPrototype:HC_anything()];
    [MKTVerifyCount(context.invocationVerifier, MKTNever()) verifyInvocationsForPrototype:HC_anything()];
}

- (void)testThatHandlingInvocationInStubbingModeKeepsContextInStubbingMode {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context updateContextMode:MCKContextModeStubbing];
    [context handleInvocation:invocation];
    
    // then
    expect(context.mode).to.equal(MCKContextModeStubbing);
}

- (void)testThatHandlingInvocationInVerificationModeDispatchesToInvocationVerifier {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context updateContextMode:MCKContextModeVerifying];
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(context.invocationVerifier) verifyInvocationsForPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocation]];
    
    [MKTVerifyCount(context.invocationRecorder, MKTNever()) handleInvocationPrototype:HC_anything()];
    [MKTVerifyCount(context.invocationStubber, MKTNever()) recordStubPrototype:HC_anything()];
}

- (void)testThatHandlingInvocationInVerificationModeKeepsContextInVerificationMode {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context updateContextMode:MCKContextModeVerifying];
    [context handleInvocation:invocation];
    
    // then
    expect(context.mode).to.equal(MCKContextModeVerifying);
}


#pragma mark - Test Error Messages

- (void)testThatFailWithReasonCallsFailureHandlerWithFormattedReason {
    // when
    [context failWithReason:@"Hello, %@!", @"World"];

    // then
    [MKTVerify(context.failureHandler) handleFailureAtLocation:context.currentLocation withReason:@"Hello, World!"];
}


#pragma mark - LEGACY TESTS: TO BE MOVED


#pragma mark - Test Invocation Stubbing

- (void)testThatContextIsInRecordingModeAfterStubbing {
    // when
    [context stubCalls:^{
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    }];
    
    // then
    expect(context.mode).to.equal(MCKContextModeRecording);
}


#pragma mark - Test Supporting Matchers

- (void)testThatMatcherCannotBeAddedToContextInRecordingMode {
    // given
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    [context updateContextMode:MCKContextModeRecording];
    
    // then
    AssertFails({
        [context pushPrimitiveArgumentMatcher:matcher];
    });
    [MKTVerifyCount(context.argumentMatcherRecorder, MKTNever()) addPrimitiveArgumentMatcher:HC_anything()];
}

- (void)testThatMatcherCanBeAddedToContextInStubbingMode {
    // given
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    [context updateContextMode:MCKContextModeStubbing];
    
    // then
    AssertDoesNotFail({
        [context pushPrimitiveArgumentMatcher:matcher];
    });
    [MKTVerify(context.argumentMatcherRecorder) addPrimitiveArgumentMatcher:matcher];
}

- (void)testThatMatcherCanBeAddedToContextInVerificationMode {
    // given
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    [context updateContextMode:MCKContextModeVerifying];
    
    // then
    AssertDoesNotFail({
        [context pushPrimitiveArgumentMatcher:matcher];
    });
    [MKTVerify(context.argumentMatcherRecorder) addPrimitiveArgumentMatcher:matcher];
}

- (void)testThatAddingMatcherReturnsMatcherIndex {
    // given
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    [MKTGiven([context.argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher]) willReturnInt:123];
    
    [context updateContextMode:MCKContextModeStubbing];
    
    // then
    expect([context pushPrimitiveArgumentMatcher:matcher]).to.equal(123);
}

@end
