//
//  MCKMockingContextTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "TestingSupport.h"

#import "MCKMockingContext.h"
#import "MCKInvocationRecorder.h"
#import "MCKInvocationStubber.h"

#import "MCKMockingContext+MCKVerification.h"
#import "MCKMockingContext+MCKArgumentRecording.h"
#import "MCKMockingContext+MCKFailureHandling.h"

#import "MCKMockingSyntax.h"
#import "MCKStub.h"
#import "MCKBlockArgumentMatcher.h"

#import "MCKDefaultVerificationHandler.h"
#import "MCKArgumentMatcherRecorder.h"


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
    
    expect(ctx1).to.beIdenticalTo(ctx2);
}

- (void)testThatGettingExistingContextReturnsExistingContextUnchanged {
    // given
    MCKMockingContext *ctx = [MCKMockingContext contextForTestCase:self];
    MCKLocation *location = [MCKLocation locationWithFileName:@"File.m" lineNumber:10];
    ctx.currentLocation = location;
    
    // when
    MCKMockingContext *existingContext = [MCKMockingContext currentContext];
    
    // then
    expect(existingContext).to.beIdenticalTo(ctx);
    expect(existingContext.currentLocation).to.equal(location);
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
    XCTAssertTrue([context.invocationRecorder.recordedInvocations containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Stubbing

- (void)testThatHandlingInvocationInStubbingModeDoesNotAddToRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertFalse([context.invocationRecorder.recordedInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testThatHandlingInvocationInStubbingModeStubsCalledMethod {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    XCTAssertTrue([context.invocationStubber hasStubsRecordedForInvocation:invocation], @"Invocation was not stubbed");
}

- (void)testThatUnhandledMethodIsNotStubbed {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *stubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    NSInvocation *unstubbedInvocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)];
    
    // when
    [context handleInvocation:stubbedInvocation];
    
    // then
    XCTAssertFalse([context.invocationStubber hasStubsRecordedForInvocation:unstubbedInvocation], @"Invocation was not stubbed");
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

- (void)testThatContextIsInRecordingModeAfterStubbing {
    // when
    [context stubCalls:^{
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    }];
    
    // then
    XCTAssertEqual(context.mode, MCKContextModeRecording, @"Adding an action did not switch to recording mode");
}


#pragma mark - Test Invocation Verification

- (void)testThatHandlingInvocationInVerificationModeDoesNotAddToRecordedInvocations {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    IgnoreFailures({
        [context verifyCalls:^{
            [context handleInvocation:invocation];
        } usingCollector:nil];
    });
    
    // then
    XCTAssertFalse([context.invocationRecorder.recordedInvocations containsObject:invocation], @"Invocation was recorded");
}

- (void)testSuspendingVerificationSetsRecordingMode {
    [context verifyCalls:^{
        [context suspendVerification];
        expect(context.mode).to.equal(MCKContextModeRecording);
    } usingCollector:nil];
}

- (void)testResumingVerificationSetsVerificationMode {
    [context verifyCalls:^{
        [context suspendVerification];
        [context resumeVerification];
        expect(context.mode).to.equal(MCKContextModeVerifying);
    } usingCollector:nil];
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
    [context updateContextMode:MCKContextModeStubbing];
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher];
    
    // then
    XCTAssertEqualObjects(context.argumentMatcherRecorder.argumentMatchers, @[ matcher ], @"Argument matcher was not recorded");
}

- (void)testThatMatcherCanBeAddedToContextInVerificationMode {
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    [context verifyCalls:^{
        [context pushPrimitiveArgumentMatcher:matcher];
        expect(context.argumentMatcherRecorder.argumentMatchers).to.equal(@[ matcher ]);
        [context clearArgumentMatchers];
    } usingCollector:nil];
}

- (void)testThatAddingMatcherReturnsMatcherIndex {
    // given
    [context updateContextMode:MCKContextModeStubbing];
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
    [context updateContextMode:MCKContextModeStubbing];
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
    TestObject *object = mock([TestObject class]);
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:
                               @selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]]; // Prepare an invocation
    
    [context verifyCalls:^{
        [context pushPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]]; // Prepare a verify call
        
        AssertFails({
            [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:
                                       @selector(voidMethodCallWithIntParam1:intParam2:), 0, 10]];
        });
    } usingCollector:nil];
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
