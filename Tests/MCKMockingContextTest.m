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
#import "MCKArgumentMatcherRecorder.h"

#import "TestExceptionUtils.h"
#import "NSInvocation+TestSupport.h"
#import "MCKBlockArgumentMatcher.h"
#import "TestObject.h"
#import "FakeFailureHandler.h"


@interface MCKMockingContextTest : XCTestCase @end
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
    XCTAssertTrue(context.mode == MCKContextModeRecording, @"Should by default be in recording mode");
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertTrue([context.recordedInvocations containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Stubbing

- (void)testThatHandlingInvocationInStubbingModeDoesNotAddToRecordedInvocations {
    // given
    [context beginStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertFalse([context.recordedInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatHandlingInvocationInStubbingModeStubsCalledMethod {
    // given
    [context beginStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertTrue([context isInvocationStubbed:invocation], @"Invocation was not stubbed");
}

- (void)testThatUnhandledMethodIsNotStubbed {
    // given
    [context beginStubbing];
    NSInvocation *stubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    NSInvocation *unstubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)];
    
    // when
    [context handleInvocation:stubbedInvocation];
    
    // then
    XCTAssertFalse([context isInvocationStubbed:unstubbedInvocation], @"Invocation was not stubbed");
}

- (void)testThatModeIsNotSwitchedAfterHandlingInvocation {
    // given
    [context beginStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertEqual(context.mode, MCKContextModeStubbing, @"Stubbing mode was not permanent");
}

- (void)testThatAddingStubActionSwitchesToRecordingMode {
    // given
    [context beginStubbing];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    
    // when
    [context addStubAction:[[MCKReturnStubAction alloc] init]];
    
    // then
    XCTAssertEqual(context.mode, MCKContextModeRecording, @"Adding an action did not switch to recording mode");
}


#pragma mark - Test Invocation Verification

- (void)testThatHandlingInvocationInVerificationModeDoesNotAddToRecordedInvocations {
    // given
    [context beginVerification];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    IgnoreFailures({
        [context handleInvocation:invocation];
    });
    
    // then
    XCTAssertFalse([context.recordedInvocations containsObject:invocation], @"Invocation was recorded");
}


#pragma mark - Test Supporting Matchers

- (void)testThatMatcherCannotBeAddedToContextInRecordingMode {
    // given
    XCTAssertTrue(context.mode == MCKContextModeRecording, @"Should by default be in recording mode");
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    
    // then
    AssertFails({
        [context pushPrimitiveArgumentMatcher:matcher];
    });
}

- (void)testThatMatcherCanBeAddedToContextInStubbingMode {
    // given
    [context beginStubbing];
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher];
    
    // then
    XCTAssertEqualObjects(context.argumentMatcherRecorder.argumentMatchers, @[ matcher ], @"Argument matcher was not recorded");
}

- (void)testThatMatcherCanBeAddedToContextInVerificationMode {
    // given
    [context beginVerification];
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher];
    
    // then
    XCTAssertEqualObjects(context.argumentMatcherRecorder.argumentMatchers, @[ matcher ], @"Argument matcher was not recorded");
}

- (void)testThatAddingMatcherReturnsMatcherIndex {
    // given
    [context beginStubbing];
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
    [context beginStubbing];
    [context pushPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [context pushPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    [context handleInvocation:[NSInvocation invocationForTarget:object
                                           selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 1]];
    
    // then
    XCTAssertEqual([context.argumentMatcherRecorder.argumentMatchers count], (NSUInteger)0,
                   @"Argument matchers were not cleared after -handleInvocation:");
}

- (void)testThatVerificationInvocationFailsForUnequalNumberOfPrimitiveMatchers {
    // given
    TestObject *object = mock([TestObject class]);
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]]; // Prepare an invocation
    
    [context beginVerification];
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
