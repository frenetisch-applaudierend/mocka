//
//  MCKMockingContextTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKMockingContext.h"
#import "MCKMockingSyntax.h"

#import "MCKDefaultVerificationHandler.h"
#import "MCKReturnStubAction.h"
#import "MCKInvocationCollection.h"
#import "MCKArgumentMatcherCollection.h"

#import "TestExceptionUtils.h"
#import "NSInvocation+TestSupport.h"
#import "MCKBlockArgumentMatcher.h"
#import "TestObject.h"
#import "FakeFailureHandler.h"
#import "FakeVerifier.h"


@interface MCKMockingContextTest : XCTestCase
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
    id ctx1 = [MCKMockingContext contextForTestCase:self];
    id ctx2 = [MCKMockingContext contextForTestCase:self];
    XCTAssertEqualObjects(ctx1, ctx2, @"Not the same context returned");
}

- (void)testThatUpdatingLocationOnContextUpdatesFileLocationInformationOnErrorHandler {
    MCKMockingContext *ctx = [MCKMockingContext contextForTestCase:self];
    
    [ctx updateFileName:@"Foo" lineNumber:10];
    XCTAssertEqualObjects(ctx.failureHandler.fileName, @"Foo", @"File name not updated");
    XCTAssertEqual(ctx.failureHandler.lineNumber, (NSUInteger)10, @"Line number not updated");
    
    [ctx updateFileName:@"Bar" lineNumber:20];
    XCTAssertEqualObjects(ctx.failureHandler.fileName, @"Bar", @"File name not updated");
    XCTAssertEqual(ctx.failureHandler.lineNumber, (NSUInteger)20, @"Line number not updated");
}

- (void)testThatGettingExistingContextReturnsExistingContextUnchanged {
    // given
    MCKMockingContext *ctx = [MCKMockingContext contextForTestCase:self];
    [ctx updateFileName:@"Foo" lineNumber:10];
    
    // when
    MCKMockingContext *existingContext = [MCKMockingContext currentContext];
    
    // then
    XCTAssertEqual(ctx, existingContext, @"Not the same context returned");
    XCTAssertEqual(existingContext.failureHandler.fileName, @"Foo", @"Filename was changed");
    XCTAssertEqual(existingContext.failureHandler.lineNumber, (NSUInteger)10, @"Linenumber was changed");
}

- (void)testThatGettingExistingContextAlwaysGetsLatestContext {
    // given
    MCKMockingContext *oldCtx = [[MCKMockingContext alloc] initWithTestCase:self];
    MCKMockingContext *newCtx = [[MCKMockingContext alloc] initWithTestCase:self];
    
    // then
    XCTAssertEqual([MCKMockingContext currentContext], newCtx, @"Context was not updated");
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
    XCTAssertThrows([MCKMockingContext currentContext], @"Getting a context before it's created should fail");
}


#pragma mark - Test Invocation Recording

- (void)testThatHandlingInvocationInRecordingModeAddsToRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeRecording];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertTrue([context.recordedInvocations.allInvocations containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Stubbing

- (void)testThatHandlingInvocationInStubbingModeDoesNotAddToRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertFalse([context.recordedInvocations.allInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatHandlingInvocationInStubbingModeStubsCalledMethod {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertTrue([context isInvocationStubbed:invocation], @"Invocation was not stubbed");
}

- (void)testThatUnhandledMethodIsNotStubbed {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *stubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    NSInvocation *unstubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)];
    
    // when
    [context handleInvocation:stubbedInvocation];
    
    // then
    XCTAssertFalse([context isInvocationStubbed:unstubbedInvocation], @"Invocation was not stubbed");
}

- (void)testThatModeIsNotSwitchedAfterHandlingInvocation {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertEqual(context.mode, MCKContextModeStubbing, @"Stubbing mode was not permanent");
}

- (void)testThatAddingStubActionSwitchesToRecordingMode {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    
    // when
    [context addStubAction:[[MCKReturnStubAction alloc] init]];
    
    // then
    XCTAssertEqual(context.mode, MCKContextModeRecording, @"Adding an action did not switch to recording mode");
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
    XCTAssertFalse([context.recordedInvocations.allInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatSettingVerificationModeSetsDefaultVerificationHandler {
    // given
    context.verificationHandler = nil;
    XCTAssertNil(context.verificationHandler, @"verificationHandler was stil set after setting to nil");
    
    // when
    [context updateContextMode:MCKContextModeVerifying];
    
    // then
    XCTAssertEqualObjects(context.verificationHandler, [MCKDefaultVerificationHandler defaultHandler], @"Not the expected verificationHanlder set");
}

- (void)testThatHandlingInvocationInVerificationModeCallsVerifier {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] init];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertEqualObjects([(FakeVerifier *)context.verifier lastPassedInvocation], invocation, @"Wrong invocation passed");
    XCTAssertEqualObjects([(FakeVerifier *)context.verifier lastPassedMatchers], context.argumentMatchers, @"Wrong matchers passed");
    XCTAssertEqualObjects([(FakeVerifier *)context.verifier lastPassedRecordedInvocations], context.recordedInvocations, @"Wrong invocation passed");
}

- (void)testThatHandlingInvocationInVerificationModeUpdatesToModeReturnedByVerifier {
    // Test for switch to recording mode
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] initWithNewContextMode:MCKContextModeRecording];
    [context handleInvocation:nil];
    XCTAssertEqual(context.mode, MCKContextModeRecording, @"Wrong context mode");
    
    // Test for switch to verification mode
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] initWithNewContextMode:MCKContextModeVerifying];
    [context handleInvocation:nil];
    XCTAssertEqual(context.mode, MCKContextModeVerifying, @"Wrong context mode");
    
    // Test for switch to stubbing mode
    [context updateContextMode:MCKContextModeVerifying];
    context.verifier = [[FakeVerifier alloc] initWithNewContextMode:MCKContextModeStubbing];
    [context handleInvocation:nil];
    XCTAssertEqual(context.mode, MCKContextModeStubbing, @"Wrong context mode");
}


#pragma mark - Test Supporting Matchers

- (void)testThatMatcherCannotBeAddedToContextInRecordingMode {
    // given
    [context updateContextMode:MCKContextModeRecording];
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    
    // then
    AssertFails({
        [context pushPrimitiveArgumentMatcher:matcher];
    });
}

- (void)testThatMatcherCanBeAddedToContextInStubbingMode {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher];
    
    // then
    XCTAssertEqual([context.primitiveArgumentMatchers count], (NSUInteger)1, @"Argument matcher was not recorded");
    XCTAssertEqual([context.primitiveArgumentMatchers lastObject], matcher, @"Argument matcher was not recorded");
}

- (void)testThatMatcherCanBeAddedToContextInVerificationMode {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher];
    
    // then
    XCTAssertEqual([context.primitiveArgumentMatchers count], (NSUInteger)1, @"Argument matcher was not recorded");
    XCTAssertEqual([context.primitiveArgumentMatchers lastObject], matcher, @"Argument matcher was not recorded");
}

- (void)testThatAddingMatcherReturnsMatcherIndex {
    // given
    [context updateContextMode:MCKContextModeStubbing]; // Fulfill precondition
    id matcher0 = [[MCKBlockArgumentMatcher alloc] init];
    id matcher1 = [[MCKBlockArgumentMatcher alloc] init];
    id matcher2 = [[MCKBlockArgumentMatcher alloc] init];
    
    // then
    XCTAssertEqual([context pushPrimitiveArgumentMatcher:matcher0], (uint8_t)0, @"Wrong index returned for matcher");
    XCTAssertEqual([context pushPrimitiveArgumentMatcher:matcher1], (uint8_t)1, @"Wrong index returned for matcher");
    XCTAssertEqual([context pushPrimitiveArgumentMatcher:matcher2], (uint8_t)2, @"Wrong index returned for matcher");
}

- (void)testThatHandlingInvocationClearsPushedMatchers {
    // given
    TestObject *object = [[TestObject alloc] init];
    [context updateContextMode:MCKContextModeStubbing]; // Fulfill precondition
    [context pushPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [context pushPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 1]];
    
    // then
    XCTAssertEqual([context.primitiveArgumentMatchers count], (NSUInteger)0, @"Argument matchers were not cleared after -handleInvocation:");
}

- (void)testThatVerificationInvocationFailsForUnequalNumberOfPrimitiveMatchers {
    // given
    TestObject *object = mock([TestObject class]);
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]]; // Prepare an invocation
    
    [context updateContextMode:MCKContextModeVerifying];
    [context pushPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]]; // Prepare a verify call
    
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
    XCTAssertEqual([failures count], (NSUInteger)1, @"Should have exactly one failure");
    XCTAssertEqualObjects([[failures lastObject] reason], @"Hello, World!", @"Wrong reason in failure");
}

@end
