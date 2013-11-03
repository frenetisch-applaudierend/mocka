//
//  MCKInvocationVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKInvocationVerifier.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"

#import "BlockInvocationVerifierDelegate.h"
#import "FakeInvocationPrototype.h"
#import "FakeVerificationHandler.h"
#import "FakeVerificationResultCollector.h"
#import "FakeMockingContext.h"
#import "AsyncService.h"
#import "NSInvocation+TestSupport.h"


@interface MCKInvocationVerifierTest : XCTestCase @end
@implementation MCKInvocationVerifierTest {
    MCKInvocationVerifier *verifier;
    BlockInvocationVerifierDelegate *verifierDelegate;
    NSMutableArray *invocations;
    NSArray *results;
}

#pragma mark - Setup

- (void)setUp {
    verifierDelegate = [[BlockInvocationVerifierDelegate alloc] init];
    verifier = [[MCKInvocationVerifier alloc] init];
    verifier.delegate = verifierDelegate;
    
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
    XCTAssertTrue([verifier.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}


#pragma mark - Test Verify in Single Call Mode

- (void)testThatVerifyPassesArgumentsToVerificationHandlerInSingleMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    verifier.verificationHandler = handler;
    
    // when
    MCKInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    [verifier verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertEqualObjects([[handler.calls lastObject] prototype], prototype, @"Wrong prototype passed");
    XCTAssertEqualObjects([[handler.calls lastObject] invocations], invocations, @"Wrong invocations passed");
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessInSingleMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue(onFinishCalled, @"On finish was not called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

- (void)testThatVerifyNotifiesFirstFailureThenFinishAfterFailureInSingleMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
    NSMutableArray *calls = [NSMutableArray array];
    verifierDelegate.onFinish = ^{ [calls addObject:@"onFinish"]; };
    verifierDelegate.onFailure = ^(NSString *_){ [calls addObject:@"onFailure"]; };
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(calls, (@[ @"onFailure", @"onFinish" ]), @"Notifications not in correct order");
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterSuccessInSingleMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ invocations[0], invocations[2] ];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterFailureInSingleMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMatches:[NSIndexSet indexSetWithIndex:1]
                                                                                 reason:nil];
    NSArray *expectedRemainingInvocations = @[ invocations[0], invocations[2] ];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInSingleMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([verifier.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInSingleMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([verifier.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}


#pragma mark - Test Verify in Group Call Mode

- (void)testThatVerifyPassesArgumentsToVerificationHandlerInGroupMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    verifier.verificationHandler = handler;
    
    [verifier beginGroupRecordingWithCollector:nil];
    
    // when
    MCKInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    [verifier verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertEqualObjects([[handler.calls lastObject] prototype], prototype, @"Wrong prototype passed");
    XCTAssertEqualObjects([[handler.calls lastObject] invocations], invocations, @"Wrong invocations passed");
}

- (void)testThatVerifyDoesNotNotifyFinishOrFailureAfterSuccessInGroupMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    [verifier beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertFalse(onFinishCalled, @"On finish was called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

- (void)testThatVerifyNotifiesOnlyFailureAfterFailureInGroupMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    [verifier beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertFalse(onFinishCalled, @"On finish was called");
    XCTAssertTrue(onFailureCalled, @"On failure was not called");
}

- (void)testThatVerifyDoesNotRemoveMatchingInvocationsAfterSuccessInGroupMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    [verifier beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were removed");
}

- (void)testThatVerifyDoesNotRemoveMatchingInvocationsAfterFailureInGroupMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMatches:[NSIndexSet indexSetWithIndex:1]
                                                                                 reason:nil];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    [verifier beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were removed");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInGroupMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    [verifier beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([verifier.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInGroupMode {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    [verifier beginGroupRecordingWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([verifier.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}


#pragma mark - Test Finishing Group Mode

- (void)testThatFinishGroupPassesResultsToCollector {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collector];
    
    // begin the verification and make a few calls
    [verifier beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        verifier.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(collector.collectedResults, results, @"Wrong results passed");
}

- (void)testThatFinishGroupNotifiesOnlyFinishAfterSuccess {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collector];
    
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    // begin the verification and make a few calls
    [verifier beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        verifier.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupRecording];
    
    // then
    XCTAssertTrue(onFinishCalled, @"On finish was not called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

- (void)testThatFinishGroupNotifiesFirstFailureThenFinishAfterFailure {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSet]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    
    NSMutableArray *calls = [NSMutableArray array];
    verifierDelegate.onFinish = ^{ [calls addObject:@"onFinish"]; };
    verifierDelegate.onFailure = ^(NSString *_){ [calls addObject:@"onFailure"]; };
    
    // begin the verification and make a few calls
    [verifier beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        verifier.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(calls, (@[ @"onFailure", @"onFinish" ]), @"Notifications not in correct order");
}

- (void)testThatFinishGroupDoesNotRemoveMatchingInvocationsAfterSuccess {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    // begin the verification and make a few calls
    [verifier beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        verifier.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatFinishGroupDoesNotRemoveMatchingInvocationsAfterFailure {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    NSArray *expectedRemainingInvocations = [invocations copy];
    
    // begin the verification and make a few calls
    [verifier beginGroupRecordingWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        verifier.verificationHandler = [FakeVerificationHandler handlerWithResult:result];
        [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupRecording];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}


#pragma mark - Test Verification with Timeout

- (void)testThatVerifyCallsDelegateWhenProcessingTimeout {
    // given
    verifier.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    verifier.timeout = 0.1;
    
    __block BOOL willProcessCalled = NO; verifierDelegate.onWillProcessTimeout = ^{ willProcessCalled = YES; };
    __block BOOL didProcessCalled = NO; verifierDelegate.onDidProcessTimeout = ^{ didProcessCalled = YES; };
    
    // when
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue(willProcessCalled, @"Was not suspended");
    XCTAssertTrue(didProcessCalled, @"Was not resumed");
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessWithTimeout {
    // given
    __block BOOL shouldSucceed = NO;
    MCKVerificationResult *successResult = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    MCKVerificationResult *failureResult = [MCKVerificationResult failureWithReason:@"" matchingIndexes:[NSIndexSet indexSet]];
    
    verifier.timeout = 1.0;
    verifier.verificationHandler = [FakeVerificationHandler handlerWithImplementation:
                                   ^MCKVerificationResult *(MCKInvocationPrototype *p, NSArray *a) {
                                       return (shouldSucceed ? successResult : failureResult);
                                   }];
    
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    
    // when
    [[AsyncService sharedService] callBlockDelayed:^{
        shouldSucceed = YES;
    }];
    
    [verifier verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue(onFinishCalled, @"On finish was not called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

@end
