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
#import "MCKArgumentMatcherRecorder.h"
#import "MCKFailureHandler.h"

#import "MCKAPIMisuse.h"
#import "MCKBlockArgumentMatcher.h"
#import "MCKInvocationPrototype.h"


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


#pragma mark - Test Handling Invocations Preparations

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


KNMParametersFor(testThatHandlingInvocationSucceedsIfArgumentMatchersAreGivenInMode, @[
    @(MCKContextModeStubbing), @(MCKContextModeVerifying)
])
- (void)testThatHandlingInvocationSucceedsIfArgumentMatchersAreGivenInMode:(MCKContextMode)mode
{
    // given
    [context updateContextMode:mode];
    
    NSArray *matchers = @[ [[MCKBlockArgumentMatcher alloc] init] ];
    [MKTGiven([context.argumentMatcherRecorder argumentMatchers]) willReturn:matchers];
    
    // then
    expect(^{
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    }).toNot.raiseAny();
}

- (void)testThatHandlingInvocationFailsIfArgumentMatchersAreGivenInRecordingMode
{
    // given
    [context updateContextMode:MCKContextModeRecording];
    
    NSArray *matchers = @[ [[MCKBlockArgumentMatcher alloc] init] ];
    [MKTGiven([context.argumentMatcherRecorder argumentMatchers]) willReturn:matchers];
    
    // then
    expect(^{
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    }).to.raise(MCKAPIMisuseException);
}


#pragma mark - Test Handling Invocations Dispatching

- (void)testThatHandlingInvocationInRecordingModeDispatchesToInvocationRecorder {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation];
    
    // when
    [context updateContextMode:MCKContextModeRecording];
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(context.invocationRecorder) recordInvocationFromPrototype:prototype];
    
    [MKTVerifyCount(context.invocationStubber, MKTNever()) recordStubPrototype:HC_anything()];
    [MKTVerifyCount(context.invocationVerifier, MKTNever()) verifyInvocationsForPrototype:HC_anything()];
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
    
    [MKTVerifyCount(context.invocationRecorder, MKTNever()) recordInvocationFromPrototype:HC_anything()];
    [MKTVerifyCount(context.invocationVerifier, MKTNever()) verifyInvocationsForPrototype:HC_anything()];
}

- (void)testThatHandlingInvocationInVerificationModeDispatchesToInvocationVerifier {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context updateContextMode:MCKContextModeVerifying];
    [context handleInvocation:invocation];
    
    // then
    [MKTVerify(context.invocationVerifier) verifyInvocationsForPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocation]];
    
    [MKTVerifyCount(context.invocationRecorder, MKTNever()) recordInvocationFromPrototype:HC_anything()];
    [MKTVerifyCount(context.invocationStubber, MKTNever()) recordStubPrototype:HC_anything()];
}

KNMParametersFor(testThatHandlingInvocationDoesNotChangeContextMode, @[
    @(MCKContextModeRecording), @(MCKContextModeStubbing), @(MCKContextModeVerifying)
]);
- (void)testThatHandlingInvocationDoesNotChangeContextMode:(MCKContextMode)mode
{
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context updateContextMode:mode];
    [context handleInvocation:invocation];
    
    // then
    expect(context.mode).to.equal(mode);
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

@end
