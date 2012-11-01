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
#import "MCKInvocationRecorder.h"
#import "MCKArgumentMatcherCollection.h"

#import "TestExceptionUtils.h"
#import "NSInvocation+TestSupport.h"
#import "BlockArgumentMatcher.h"
#import "TestObject.h"


@interface FakeVerificationHandler : NSObject <MCKVerificationHandler>

+ (id)handlerWhichFailsWithMessage:(NSString *)message;
+ (id)handlerWhichReturns:(NSIndexSet *)indexSet isSatisfied:(BOOL)isSatisfied;

@property (nonatomic, readonly) NSUInteger numberOfCalls;

@property (nonatomic, readonly) NSInvocation *lastInvocationPrototype;
@property (nonatomic, readonly) NSArray      *lastArgumentMatchers;
@property (nonatomic, readonly) NSArray      *lastRecordedInvocations;

@end

@implementation FakeVerificationHandler {
    NSIndexSet *_result;
    BOOL        _satisfied;
    NSString   *_failureMessage;
}

#pragma mark - Initialization

+ (id)handlerWhichFailsWithMessage:(NSString *)message {
    return [[self alloc] initWithResult:[NSIndexSet indexSet] isSatisfied:NO failureMessage:message];
}

+ (id)handlerWhichReturns:(NSIndexSet *)indexSet isSatisfied:(BOOL)isSatisfied {
    return [[self alloc] initWithResult:indexSet isSatisfied:isSatisfied failureMessage:nil];
}

- (id)initWithResult:(NSIndexSet *)result isSatisfied:(BOOL)satisfied failureMessage:(NSString *)message {
    if ((self = [super init])) {
        _result = [result copy];
        _satisfied = satisfied;
        _failureMessage = [message copy];
    }
    return self;
}


#pragma mark - MCKVerificationHandler

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)argumentMatchers
                     inInvocationRecorder:(MCKInvocationRecorder *)recorder
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    _lastInvocationPrototype = prototype;
    _lastArgumentMatchers = [argumentMatchers.primitiveArgumentMatchers copy];
    _lastRecordedInvocations = [recorder.recordedInvocations copy];
    _numberOfCalls++;
    
    if (satisified != NULL) *satisified = _satisfied;
    if (failureMessage != NULL) *failureMessage = [_failureMessage copy];
    return _result;
}

@end


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

- (void)testThatGettingContextUpdatesFileLocationInformationInFailureHandler {
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
    STAssertTrue(ctx == existingContext, @"Not the same context returned");
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
    STAssertTrue([context.recordedInvocations containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Stubbing

- (void)testThatHandlingInvocationInStubbingModeDoesNotAddToRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertFalse([context.recordedInvocations containsObject:invocation], @"Invocation was recorded");
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
    STAssertFalse([context.recordedInvocations containsObject:invocation], @"Invocation was recorded");
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

- (void)testThatHandlingInvocationInVerificationModeCallsVerificationHandler {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    
    // when
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    
    // then
    STAssertEquals([(FakeVerificationHandler *)context.verificationHandler numberOfCalls], (NSUInteger)1, @"Number of calls is wrong");
}

- (void)testThatHandlingInvocationInVerificationModeThrowsIfHandlerIsNotSatisfied {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    
    // then
    AssertFails({
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    });
}

- (void)testThatHandlingInvocationInVerificationModeRemovesMatchingInvocationsFromRecordedInvocations {
    // given
    [context updateContextMode:MCKContextModeRecording];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]]; // record some calls
    STAssertEquals([context.recordedInvocations count], (NSUInteger)3, @"Calls were not recorded");
    
    [context updateContextMode:MCKContextModeVerifying];
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

- (void)testThatHandlingInvocationInVerificationModePassesMatchers {
    // given
    TestObject *object = [[TestObject alloc] init];
    id matcher0 = [[BlockArgumentMatcher alloc] init];
    id matcher1 = [[BlockArgumentMatcher alloc] init];
    
    [context updateContextMode:MCKContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    
    // when
    [context pushPrimitiveArgumentMatcher:matcher0];
    [context pushPrimitiveArgumentMatcher:matcher1];
    [context handleInvocation:[NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 1]];
    
    // then
    STAssertEquals([[(FakeVerificationHandler *)context.verificationHandler lastArgumentMatchers] count], (NSUInteger)2, @"Number of matchers is wrong");
    STAssertEquals([(FakeVerificationHandler *)context.verificationHandler lastArgumentMatchers][0], matcher0, @"Wrong matcher");
    STAssertEquals([(FakeVerificationHandler *)context.verificationHandler lastArgumentMatchers][1], matcher1, @"Wrong matcher");
}


#pragma mark - Test Error Messages

- (void)testThatContextFailsWithCorrectErrorMessageForFailedVerify {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:@"Foo was never called"];
    
    // then
    AssertFailsWith(@"verify: Foo was never called", nil, 0, {
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    });
}

- (void)testThatContextFailsWithDefaultErrorMessageForVerifyIfTheHandlerDoesNotProvideOne {
    // given
    [context updateContextMode:MCKContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMessage:nil];
    
    // then
    AssertFailsWith(@"verify: failed with an unknown reason", nil, 0, {
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    });
}

@end
