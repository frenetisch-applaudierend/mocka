//
//  MCKVerificationSessionTest.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKVerificationSession.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"

#import "FakeInvocationPrototype.h"
#import "FakeVerificationHandler.h"
#import "FakeVerificationResultCollector.h"
#import "FakeMockingContext.h"
#import "AsyncService.h"
#import "NSInvocation+TestSupport.h"


@interface VerificationSessionDelegate : NSObject <MCKVerificationSessionDelegate>

@property (nonatomic, copy) void(^onFailure)(NSString *reason);
@property (nonatomic, copy) void(^onFinish)(void);
@property (nonatomic, copy) void(^onWillProcessTimeout)(void);
@property (nonatomic, copy) void(^onDidProcessTimeout)(void);

@end


@interface MCKVerificationSessionTest : XCTestCase @end
@implementation MCKVerificationSessionTest {
    MCKVerificationSession *session;
    VerificationSessionDelegate *sessionDelegate;
    NSMutableArray *invocations;
    NSArray *results;
}

#pragma mark - Setup

- (void)setUp {
    sessionDelegate = [[VerificationSessionDelegate alloc] init];
    session = [[MCKVerificationSession alloc] init];
    session.delegate = sessionDelegate;
    
    invocations = [NSMutableArray arrayWithObjects:
                   [NSInvocation voidMethodInvocationForTarget:nil],
                   [NSInvocation voidMethodInvocationForTarget:nil],
                   [NSInvocation voidMethodInvocationForTarget:nil], nil];
    
    results = @[
        [MCKVerificationResult successWithMatchingIndexes:nil],
        [MCKVerificationResult successWithMatchingIndexes:nil],
        [MCKVerificationResult successWithMatchingIndexes:nil]
    ];
}


#pragma mark - Test Initialization

- (void)testThatDefaultHandlerIsSet {
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}


#pragma mark - Test Verify in Single Call Mode

- (void)testThatVerifyPassesArgumentsToVerificationHandlerInSingleMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    session.verificationHandler = handler;
    
    // when
    MCKInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    [session verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertEqualObjects([[handler.calls lastObject] prototype], prototype, @"Wrong prototype passed");
    XCTAssertEqualObjects([[handler.calls lastObject] invocations], invocations, @"Wrong invocations passed");
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    __block BOOL onFinishCalled = NO; sessionDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; sessionDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue(onFinishCalled, @"On finish was not called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

- (void)testThatVerifyNotifiesFirstFailureThenFinishAfterFailureInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
    NSMutableArray *calls = [NSMutableArray array];
    sessionDelegate.onFinish = ^{ [calls addObject:@"onFinish"]; };
    sessionDelegate.onFailure = ^(NSString *_){ [calls addObject:@"onFailure"]; };
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(calls, (@[ @"onFailure", @"onFinish" ]), @"Notifications not in correct order");
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterSuccessInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ invocations[0], invocations[2] ];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterFailureInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMatches:[NSIndexSet indexSetWithIndex:1]
                                                                                 reason:nil];
    NSArray *expectedRemainingInvocations = @[ invocations[0], invocations[2] ];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}


#pragma mark - Test Verify in Group Call Mode

- (void)testThatVerifyPassesArgumentsToVerificationHandlerInGroupMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    session.verificationHandler = handler;
    
    [session beginGroupRecordingWithCollector:nil];
    
    // when
    MCKInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    [session verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertEqualObjects([[handler.calls lastObject] prototype], prototype, @"Wrong prototype passed");
    XCTAssertEqualObjects([[handler.calls lastObject] invocations], invocations, @"Wrong invocations passed");
}

- (void)testThatVerifyDoesNotNotifyFinishOrFailureAfterSuccessInGroupMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    __block BOOL onFinishCalled = NO; sessionDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; sessionDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    [session beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertFalse(onFinishCalled, @"On finish was called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

- (void)testThatVerifyNotifiesOnlyFailureAfterFailureInGroupMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    __block BOOL onFinishCalled = NO; sessionDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; sessionDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    [session beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertFalse(onFinishCalled, @"On finish was called");
    XCTAssertTrue(onFailureCalled, @"On failure was not called");
}

- (void)testThatVerifyDoesNotRemoveMatchingInvocationsAfterSuccessInGroupMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    [session beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were removed");
}

- (void)testThatVerifyDoesNotRemoveMatchingInvocationsAfterFailureInGroupMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMatches:[NSIndexSet indexSetWithIndex:1]
                                                                                 reason:nil];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    [session beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were removed");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInGroupMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    [session beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInGroupMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    [session beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}


#pragma mark - Test Finishing Group Mode

- (void)testThatFinishGroupPassesResultsToCollector {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collector];
    
    // begin the session and make a few calls
    [session beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        session.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [session finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(collector.collectedResults, results, @"Wrong results passed");
}

- (void)testThatFinishGroupNotifiesOnlyFinishAfterSuccess {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collector];
    
    __block BOOL onFinishCalled = NO; sessionDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; sessionDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    // begin the session and make a few calls
    [session beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        session.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [session finishGroupRecording];
    
    // then
    XCTAssertTrue(onFinishCalled, @"On finish was not called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

- (void)testThatFinishGroupNotifiesFirstFailureThenFinishAfterFailure {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSet]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    
    NSMutableArray *calls = [NSMutableArray array];
    sessionDelegate.onFinish = ^{ [calls addObject:@"onFinish"]; };
    sessionDelegate.onFailure = ^(NSString *_){ [calls addObject:@"onFailure"]; };
    
    // begin the session and make a few calls
    [session beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        session.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [session finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(calls, (@[ @"onFailure", @"onFinish" ]), @"Notifications not in correct order");
}

- (void)testThatFinishGroupDoesNotRemoveMatchingInvocationsAfterSuccess {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    // begin the session and make a few calls
    [session beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        session.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [session finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatFinishGroupDoesNotRemoveMatchingInvocationsAfterFailure {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    // begin the session and make a few calls
    [session beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        session.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [session finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}


#pragma mark - Test Verification with Timeout

- (void)testThatVerifyCallsDelegateWhenProcessingTimeout {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    session.timeout = 0.1;
    
    __block BOOL willProcessCalled = NO; sessionDelegate.onWillProcessTimeout = ^{ willProcessCalled = YES; };
    __block BOOL didProcessCalled = NO; sessionDelegate.onDidProcessTimeout = ^{ didProcessCalled = YES; };
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue(willProcessCalled, @"Was not suspended");
    XCTAssertTrue(didProcessCalled, @"Was not resumed");
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessWithTimeout {
    // given
    __block BOOL shouldSucceed = NO;
    MCKVerificationResult *successResult = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    MCKVerificationResult *failureResult = [MCKVerificationResult failureWithReason:@"" matchingIndexes:[NSIndexSet indexSet]];
    
    session.timeout = 1.0;
    session.verificationHandler = [FakeVerificationHandler handlerWithImplementation:
                                   ^MCKVerificationResult *(MCKInvocationPrototype *p, NSArray *a) {
                                       return (shouldSucceed ? successResult : failureResult);
                                   }];
    
    __block BOOL onFinishCalled = NO; sessionDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; sessionDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    
    // when
    [[AsyncService sharedService] callBlockDelayed:^{
        shouldSucceed = YES;
    }];
    
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue(onFinishCalled, @"On finish was not called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

@end


@implementation VerificationSessionDelegate

- (void)verificationSession:(MCKVerificationSession *)session didFailWithReason:(NSString *)reason {
    if (self.onFailure != nil) {
        self.onFailure(reason);
    }
}

- (void)verificationSessionDidEnd:(MCKVerificationSession *)session {
    if (self.onFinish != nil) {
        self.onFinish();
    }
}

- (void)verificationSessionWillProcessTimeout:(MCKVerificationSession *)session {
    if (self.onWillProcessTimeout != nil) {
        self.onWillProcessTimeout();
    }
}

- (void)verificationSessionDidProcessTimeout:(MCKVerificationSession *)session {
    if (self.onDidProcessTimeout != nil) {
        self.onDidProcessTimeout();
    }
}

@end
