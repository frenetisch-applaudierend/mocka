//
//  RGMockingContextTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockTestCase.h"

#import "NSInvocation+TestSupport.h"
#import "FakeVerificationHandler.h"
#import "DummyArgumentMatcher.h"
#import "MockTestObject.h"

#import "RGMockClassAndProtocolMock.h"
#import "RGMockContext.h"
#import "RGMockDefaultVerificationHandler.h"
#import "RGMockReturnStubAction.h"


@interface RGMockContextTest : RGMockTestCase
@end

@implementation RGMockContextTest {
    RGMockContext *context;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    context = [[RGMockContext alloc] initWithTestCase:self];
}


#pragma mark - Test Getting a Context

- (void)testThatGettingTheContextTwiceReturnsSameContext {
    id ctx1 = [RGMockContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    id ctx2 = [RGMockContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    STAssertEqualObjects(ctx1, ctx2, @"Not the same context returned");
}

- (void)testThatGettingContextUpdatesFileLocationInformation {
    RGMockContext *ctx = [RGMockContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    STAssertEqualObjects(ctx.fileName, @"Foo", @"File name not updated");
    STAssertEquals(ctx.lineNumber, 10, @"Line number not updated");
    
    ctx = [RGMockContext contextForTestCase:self fileName:@"Bar" lineNumber:20];
    STAssertEqualObjects(ctx.fileName, @"Bar", @"File name not updated");
    STAssertEquals(ctx.lineNumber, 20, @"Line number not updated");
}

- (void)testThatGettingExistingContextReturnsExistingContextUnchanged {
    // given
    RGMockContext *ctx = [RGMockContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    
    // when
    RGMockContext *existingContext = [RGMockContext currentContext];
    
    // then
    STAssertEquals(ctx, existingContext, @"Not the same context returned");
    STAssertEquals(existingContext.fileName, @"Foo", @"Filename was changed");
    STAssertEquals(existingContext.lineNumber, 10, @"Linenumber was changed");
}

- (void)testThatGettingExistingContextAlwaysGetsLatestContext {
    // given
    RGMockContext *oldCtx = [[RGMockContext alloc] initWithTestCase:self];
    RGMockContext *newCtx = [[RGMockContext alloc] initWithTestCase:self];
    
    // then
    STAssertEquals([RGMockContext currentContext], newCtx, @"Context was not updated");
    oldCtx = nil; // shut the compiler up
}

- (void)testThatGettingExistingContextFailsIfNoContextWasCreatedYet {
    // given
    id testCase = [[NSObject alloc] init];
    RGMockContext *ctx = [[RGMockContext alloc] initWithTestCase:testCase];
    
    // when
    ctx = nil;
    testCase = nil; // at this point the context should be deallocated
    
    // then
    STAssertThrows([RGMockContext currentContext], @"Getting a context before it's created should fail");
}


#pragma mark - Test Invocation Recording

- (void)testThatHandlingInvocationInRecordingModeAddsToRecordedInvocations {
    // given
    [context updateContextMode:RGMockContextModeRecording];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertTrue([context.recordedInvocations containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Stubbing

- (void)testThatHandlingInvocationInStubbingModeDoesNotAddToRecordedInvocations {
    // given
    [context updateContextMode:RGMockContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertFalse([context.recordedInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatHandlingInvocationInStubbingModeCreatesStubbingForCalledMethod {
    // given
    [context updateContextMode:RGMockContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertNotNil([context stubbingForInvocation:invocation], @"Invocation was not stubbed");
}

- (void)testThatNoStubbingIsReturnedForNonStubbedMethod {
    // given
    [context updateContextMode:RGMockContextModeStubbing];
    NSInvocation *stubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    NSInvocation *unstubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)];
    
    // when
    [context handleInvocation:stubbedInvocation];
    
    // then
    STAssertNil([context stubbingForInvocation:unstubbedInvocation], @"Invocation was stubbed");
}

- (void)testThatModeIsNotSwitchedAfterHandlingInvocation {
    // given
    [context updateContextMode:RGMockContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertEquals(context.mode, RGMockContextModeStubbing, @"Stubbing mode was not permanent");
}

- (void)testThatAddingStubActionSwitchesToRecordingMode {
    // given
    [context updateContextMode:RGMockContextModeStubbing];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    
    // when
    [context addStubAction:[[RGMockReturnStubAction alloc] init]];
    
    // then
    STAssertEquals(context.mode, RGMockContextModeRecording, @"Adding an action did not switch to recording mode");
}


#pragma mark - Test Invocation Verification

- (void)testThatHandlingInvocationInVerificationModeDoesNotAddToRecordedInvocations {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    IgnoreFailures({
        [context handleInvocation:invocation];
    });
    
    // then
    STAssertFalse([context.recordedInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatSettingVerificationModeSetsDefaultVerificationHandler {
    // given
    context.verificationHandler = nil;
    STAssertNil(context.verificationHandler, @"verificationHandler was stil set after setting to nil");
    
    // when
    [context updateContextMode:RGMockContextModeVerifying];
    
    // then
    STAssertEqualObjects(context.verificationHandler, [RGMockDefaultVerificationHandler defaultHandler], @"Not the expected verificationHanlder set");
}

- (void)testThatHandlingInvocationInVerificationModeCallsVerificationHandler {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    
    // when
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    
    // then
    STAssertEquals([(FakeVerificationHandler *)context.verificationHandler numberOfCalls], (NSUInteger)1, @"Number of calls is wrong");
}

- (void)testThatHandlingInvocationInVerificationModeThrowsIfHandlerIsNotSatisfied {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    
    // then
    AssertFails({
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    });
}

- (void)testThatHandlingInvocationInVerificationModeRemovesMatchingInvocationsFromRecordedInvocations {
    // given
    [context updateContextMode:RGMockContextModeRecording];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]]; // record some calls
    STAssertEquals([context.recordedInvocations count], (NSUInteger)3, @"Calls were not recorded");
    
    [context updateContextMode:RGMockContextModeVerifying];
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSetWithIndex:0]; [toRemove addIndex:2];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:toRemove isSatisfied:YES];
    
    // when
    [context handleInvocation:nil]; // any invocation is ok, just as long as the handler is called
    
    // then
    STAssertEquals([context.recordedInvocations count], (NSUInteger)1, @"Calls were not removed");
    STAssertEquals([[context.recordedInvocations lastObject] selector], @selector(tearDown), @"Wrong calls were removed");
}


#pragma mark - Test Supporting Matchers

- (void)testThatMatcherCannotBeAddedToContextInRecordingMode {
    // given
    [context updateContextMode:RGMockContextModeRecording];
    id matcher = [[DummyArgumentMatcher alloc] init];
    
    // then
    AssertFails({
        [context pushNonObjectArgumentMatcher:matcher];
    });
}

- (void)testThatMatcherCanBeAddedToContextInStubbingMode {
    // given
    [context updateContextMode:RGMockContextModeStubbing];
    id matcher = [[DummyArgumentMatcher alloc] init];
    
    // when
    [context pushNonObjectArgumentMatcher:matcher];
    
    // then
    STAssertEquals([context.nonObjectArgumentMatchers count], (uint)1, @"Argument matcher was not recorded");
    STAssertEquals([context.nonObjectArgumentMatchers lastObject], matcher, @"Argument matcher was not recorded");
}

- (void)testThatMatcherCanBeAddedToContextInVerificationMode {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    id matcher = [[DummyArgumentMatcher alloc] init];
    
    // when
    [context pushNonObjectArgumentMatcher:matcher];
    
    // then
    STAssertEquals([context.nonObjectArgumentMatchers count], (uint)1, @"Argument matcher was not recorded");
    STAssertEquals([context.nonObjectArgumentMatchers lastObject], matcher, @"Argument matcher was not recorded");
}

- (void)testThatAddingMatcherReturnsMatcherIndex {
    // given
    [context updateContextMode:RGMockContextModeStubbing]; // Fulfill precondition
    id matcher0 = [[DummyArgumentMatcher alloc] init];
    id matcher1 = [[DummyArgumentMatcher alloc] init];
    id matcher2 = [[DummyArgumentMatcher alloc] init];
    
    // then
    STAssertEquals([context pushNonObjectArgumentMatcher:matcher0], (uint8_t)0, @"Wrong index returned for matcher");
    STAssertEquals([context pushNonObjectArgumentMatcher:matcher1], (uint8_t)1, @"Wrong index returned for matcher");
    STAssertEquals([context pushNonObjectArgumentMatcher:matcher2], (uint8_t)2, @"Wrong index returned for matcher");
}

- (void)testThatHandlingInvocationClearsPushedMatchers {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    [context updateContextMode:RGMockContextModeStubbing]; // Fulfill precondition
    [context pushNonObjectArgumentMatcher:[[DummyArgumentMatcher alloc] init]];
    [context pushNonObjectArgumentMatcher:[[DummyArgumentMatcher alloc] init]];
    
    // when
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 1]];
    
    // then
    STAssertEquals([context.nonObjectArgumentMatchers count], (uint)0, @"Argument matchers were not cleared after -handleInvocation:");
}

- (void)testThatVerificationInvocationFailsForUnequalNumberOfNonObjectMatchers {
    // given
    MockTestObject *object = mock([MockTestObject class]);
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]]; // Prepare an invocation
    
    [context updateContextMode:RGMockContextModeVerifying];
    [context pushNonObjectArgumentMatcher:[[DummyArgumentMatcher alloc] init]]; // Prepare a verify call
    
    // when
    AssertFails({
        [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]];
    });
}

- (void)testThatHandlingInvocationInVerificationModePassesMatchers {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    id matcher0 = [[DummyArgumentMatcher alloc] init];
    id matcher1 = [[DummyArgumentMatcher alloc] init];
    
    [context updateContextMode:RGMockContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    
    // when
    [context pushNonObjectArgumentMatcher:matcher0];
    [context pushNonObjectArgumentMatcher:matcher1];
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 1]];
    
    // then
    STAssertEquals([[(FakeVerificationHandler *)context.verificationHandler lastArgumentMatchers] count], (uint)2, @"Number of matchers is wrong");
    STAssertEquals([(FakeVerificationHandler *)context.verificationHandler lastArgumentMatchers][0], matcher0, @"Wrong matcher");
    STAssertEquals([(FakeVerificationHandler *)context.verificationHandler lastArgumentMatchers][1], matcher1, @"Wrong matcher");
}


#pragma mark - Test Error Messages

- (void)testThatFailWithReasonCreatesSenTestException {
    RGMockContext *ctx = [RGMockContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    
    AssertFailsWith(@"Test reason", @"Foo", 10, {
        [ctx failWithReason:@"Test reason"];
    });
}

- (void)testThatContextFailsWithCorrectErrorMessageForFailedVerify {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:@"Foo was never called"];
    
    // then
    AssertFailsWith(@"verify: Foo was never called", nil, 0, {
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    });
}

- (void)testThatContextFailsWithDefaultErrorMessageForVerifyIfTheHandlerDoesNotProvideOne {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:nil];
    
    // then
    AssertFailsWith(@"verify: failed with an unknown reason", nil, 0, {
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    });
}

@end
