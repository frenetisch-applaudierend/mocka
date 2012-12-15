//
//  MCKMockingContextTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKMockingContext.h"
#import "MCKMockObject.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKReturnStubAction.h"
#import "MCKInvocationCollection.h"
#import "MCKArgumentMatcherCollection.h"

#import "TestExceptionUtils.h"
#import "NSInvocation+TestSupport.h"
#import "BlockArgumentMatcher.h"
#import "TestObject.h"
#import "FakeFailureHandler.h"
#import "FakeVerifier.h"


@interface MCKMockingContextTest : SenTestCase
@end

@implementation MCKMockingContextTest {
    MCKMockingContext *context;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    context = [[MCKMockingContext alloc] initWithTestCase:self];
    context.failureHandler = [[MCKExceptionFailureHandler alloc] init];
}


#pragma mark - Test Getting a Context

- (void)testThatGettingTheContextTwiceReturnsSameContext {
    id ctx1 = [MCKMockingContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    id ctx2 = [MCKMockingContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    STAssertEqualObjects(ctx1, ctx2, @"Not the same context returned");
}

- (void)testThatGettingContextUpdatesFileLocationInformationOnErrorHandler {
    MCKMockingContext *ctx = [MCKMockingContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    STAssertEqualObjects(ctx.failureHandler.fileName, @"Foo", @"File name not updated");
    STAssertEquals(ctx.failureHandler.lineNumber, (NSUInteger)10, @"Line number not updated");
    
    ctx = [MCKMockingContext contextForTestCase:self fileName:@"Bar" lineNumber:20];
    STAssertEqualObjects(ctx.failureHandler.fileName, @"Bar", @"File name not updated");
    STAssertEquals(ctx.failureHandler.lineNumber, (NSUInteger)20, @"Line number not updated");
}

- (void)testThatGettingExistingContextReturnsExistingContextUnchanged {
    // given
    MCKMockingContext *ctx = [MCKMockingContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    
    // when
    MCKMockingContext *existingContext = [MCKMockingContext currentContext];
    
    // then
    STAssertEquals(ctx, existingContext, @"Not the same context returned");
    STAssertEquals(existingContext.failureHandler.fileName, @"Foo", @"Filename was changed");
    STAssertEquals(existingContext.failureHandler.lineNumber, (NSUInteger)10, @"Linenumber was changed");
}

- (void)testThatGettingExistingContextAlwaysGetsLatestContext {
    // given
    MCKMockingContext *oldCtx = [[MCKMockingContext alloc] initWithTestCase:self];
    MCKMockingContext *newCtx = [[MCKMockingContext alloc] initWithTestCase:self];
    
    // then
    STAssertEquals([MCKMockingContext currentContext], newCtx, @"Context was not updated");
    oldCtx = nil; // shut the compiler up
}

- (void)testThatGettingExistingContextFailsIfNoContextWasCreatedYet {
    // given
    id testCase = [[NSObject alloc] init];
    MCKMockingContext *ctx = [[MCKMockingContext alloc] initWithTestCase:testCase];
    
    // when
    ctx = nil;
    testCase = nil; // at this point the context should be deallocated
    
    // then
    STAssertThrows([MCKMockingContext currentContext], @"Getting a context before it's created should fail");
}


#pragma mark - Test Invocation Recording

- (void)testThatHandlingInvocationInRecordingModeAddsToRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeRecording];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertTrue([context.recordedInvocations.allInvocations containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Stubbing

- (void)testThatHandlingInvocationInStubbingModeDoesNotAddToRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertFalse([context.recordedInvocations.allInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatHandlingInvocationInStubbingModeStubsCalledMethod {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertTrue([context isInvocationStubbed:invocation], @"Invocation was not stubbed");
}

- (void)testThatUnhandledMethodIsNotStubbed {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *stubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    NSInvocation *unstubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)];
    
    // when
    [context handleInvocation:stubbedInvocation];
    
    // then
    STAssertFalse([context isInvocationStubbed:unstubbedInvocation], @"Invocation was not stubbed");
}

- (void)testThatModeIsNotSwitchedAfterHandlingInvocation {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertEquals(context.mode, MCKContextModeStubbing, @"Stubbing mode was not permanent");
}

- (void)testThatAddingStubActionSwitchesToRecordingMode {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    
    // when
    [context addStubAction:[[MCKReturnStubAction alloc] init]];
    
    // then
    STAssertEquals(context.mode, MCKContextModeRecording, @"Adding an action did not switch to recording mode");
}


#pragma mark - Test Invocation Verification

- (void)testThatHandlingInvocationInVerificationModeDoesNotAddToRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    IgnoreFailures({
        [context handleInvocation:invocation];
    });
    
    // then
    STAssertFalse([context.recordedInvocations.allInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatSettingVerificationModeSetsDefaultVerificationHandler {
    // given
    context.verificationHandler = nil;
    STAssertNil(context.verificationHandler, @"verificationHandler was stil set after setting to nil");
    
    // when
    [context updateContextMode:MCKContextModeVerifying];
    
    // then
    STAssertEqualObjects(context.verificationHandler, [MCKDefaultVerificationHandler defaultHandler], @"Not the expected verificationHanlder set");
}

- (void)testThatHandlingInvocationInVerificationModeCallsVerifier {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] init];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertEqualObjects([(FakeVerifier *)context.verifier lastPassedInvocation], invocation, @"Wrong invocation passed");
    STAssertEqualObjects([(FakeVerifier *)context.verifier lastPassedMatchers], context.argumentMatchers, @"Wrong matchers passed");
    STAssertEqualObjects([(FakeVerifier *)context.verifier lastPassedRecordedInvocations], context.recordedInvocations, @"Wrong invocation passed");
}

- (void)testThatHandlingInvocationInVerificationModeUpdatesToModeReturnedByVerifier {
    // Test for switch to recording mode
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] initWithNewContextMode:MCKContextModeRecording];
    [context handleInvocation:nil];
    STAssertEquals(context.mode, MCKContextModeRecording, @"Wrong context mode");
    
    // Test for switch to verification mode
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] initWithNewContextMode:MCKContextModeVerifying];
    [context handleInvocation:nil];
    STAssertEquals(context.mode, MCKContextModeVerifying, @"Wrong context mode");
    
    // Test for switch to stubbing mode
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] initWithNewContextMode:MCKContextModeStubbing];
    [context handleInvocation:nil];
    STAssertEquals(context.mode, MCKContextModeStubbing, @"Wrong context mode");
}


#pragma mark - Test Supporting Matchers

- (void)testThatMatcherCannotBeAddedToContextInRecordingMode {
    // given
    [context updateContextMode:MCKContextModeRecording];
    id matcher = [[BlockArgumentMatcher alloc] init];
    
    // then
    AssertFails({
        [context pushPrimitiveArgumentMatcher:matcher];
    });
}

- (void)testThatMatcherCanBeAddedToContextInStubbingMode {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    id matcher = [[BlockArgumentMatcher alloc] init];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher];
    
    // then
    STAssertEquals([context.primitiveArgumentMatchers count], (NSUInteger)1, @"Argument matcher was not recorded");
    STAssertEquals([context.primitiveArgumentMatchers lastObject], matcher, @"Argument matcher was not recorded");
}

- (void)testThatMatcherCanBeAddedToContextInVerificationMode {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    id matcher = [[BlockArgumentMatcher alloc] init];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher];
    
    // then
    STAssertEquals([context.primitiveArgumentMatchers count], (NSUInteger)1, @"Argument matcher was not recorded");
    STAssertEquals([context.primitiveArgumentMatchers lastObject], matcher, @"Argument matcher was not recorded");
}

- (void)testThatAddingMatcherReturnsMatcherIndex {
    // given
    [context updateContextMode:MCKContextModeStubbing]; // Fulfill precondition
    id matcher0 = [[BlockArgumentMatcher alloc] init];
    id matcher1 = [[BlockArgumentMatcher alloc] init];
    id matcher2 = [[BlockArgumentMatcher alloc] init];
    
    // then
    STAssertEquals([context pushPrimitiveArgumentMatcher:matcher0], (uint8_t)0, @"Wrong index returned for matcher");
    STAssertEquals([context pushPrimitiveArgumentMatcher:matcher1], (uint8_t)1, @"Wrong index returned for matcher");
    STAssertEquals([context pushPrimitiveArgumentMatcher:matcher2], (uint8_t)2, @"Wrong index returned for matcher");
}

- (void)testThatHandlingInvocationClearsPushedMatchers {
    // given
    TestObject *object = [[TestObject alloc] init];
    [context updateContextMode:MCKContextModeStubbing]; // Fulfill precondition
    [context pushPrimitiveArgumentMatcher:[[BlockArgumentMatcher alloc] init]];
    [context pushPrimitiveArgumentMatcher:[[BlockArgumentMatcher alloc] init]];
    
    // when
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 1]];
    
    // then
    STAssertEquals([context.primitiveArgumentMatchers count], (NSUInteger)0, @"Argument matchers were not cleared after -handleInvocation:");
}

- (void)testThatVerificationInvocationFailsForUnequalNumberOfPrimitiveMatchers {
    // given
    TestObject *object = mock([TestObject class]);
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]]; // Prepare an invocation
    
    [context updateContextMode:MCKContextModeVerifying];
    [context pushPrimitiveArgumentMatcher:[[BlockArgumentMatcher alloc] init]]; // Prepare a verify call
    
    // when
    AssertFails({
        [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]];
    });
}


#pragma mark - Test Error Messages

- (void)testThatFailWithReasonCallsFailureHandlerWithFormattedReason {
    // given
    context.failureHandler = [[FakeFailureHandler alloc] init];
    
    // when
    [context failWithReason:@"Hello, %@!", @"World"];
    
    // then
    NSArray *failures = [(FakeFailureHandler *)context.failureHandler capturedFailures];
    STAssertEquals([failures count], (NSUInteger)1, @"Should have exactly one failure");
    STAssertEqualObjects([[failures lastObject] reason], @"Hello, World!", @"Wrong reason in failure");
}

@end
