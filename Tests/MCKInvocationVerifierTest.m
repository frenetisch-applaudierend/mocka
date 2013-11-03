//
//  MCKInvocationVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#define EXP_SHORTHAND
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

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
    MCKInvocationRecorder *invocationRecorder;
    NSArray *results;
}

#pragma mark - Setup

- (void)setUp {
    verifierDelegate = [[BlockInvocationVerifierDelegate alloc] init];
    verifier = [[MCKInvocationVerifier alloc] init];
    verifier.delegate = verifierDelegate;
    
    invocationRecorder = [[MCKInvocationRecorder alloc] init];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    
    results = @[
        [MCKVerificationResult successWithMatchingIndexes:nil],
        [MCKVerificationResult successWithMatchingIndexes:nil],
        [MCKVerificationResult successWithMatchingIndexes:nil]
    ];
}


#pragma mark - Test Initialization

- (void)testThatDefaultHandlerIsSet {
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}


#pragma mark - Test Verify in Single Call Mode

- (void)testThatVerifyPassesArgumentsToVerificationHandlerInSingleMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    MCKInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:handler];
    [verifier verifyInvocationsForPrototype:prototype];
    
    // then
    expect([[handler.calls lastObject] prototype]).to.equal(prototype);
    expect([[handler.calls lastObject] invocations]).to.equal(invocationRecorder.recordedInvocations);
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessInSingleMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(onFailureCalled).to.beTruthy();
    expect(onFailureCalled).to.beFalsy();
}

- (void)testThatVerifyNotifiesFirstFailureThenFinishAfterFailureInSingleMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    
    NSMutableArray *calls = [NSMutableArray array];
    verifierDelegate.onFinish = ^{ [calls addObject:@"onFinish"]; };
    verifierDelegate.onFailure = ^(NSString *_){ [calls addObject:@"onFailure"]; };
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(calls).to.equal(@[ @"onFailure", @"onFinish" ]); // must be in correct order
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterSuccessInSingleMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceedsWithMatches:[NSIndexSet indexSetWithIndex:1]]];
    NSArray *expectedRemainingInvocations = @[
        [invocationRecorder invocationAtIndex:0], [invocationRecorder invocationAtIndex:2]
    ];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterFailureInSingleMode {
    // given
    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithMatches:matches reason:nil]];
    NSArray *expectedRemainingInvocations = @[
        [invocationRecorder invocationAtIndex:0], [invocationRecorder invocationAtIndex:2]
    ];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInSingleMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInSingleMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}


#pragma mark - Test Verify in Group Call Mode

- (void)testThatVerifyPassesArgumentsToVerificationHandlerInGroupMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    MCKInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    [verifier verifyInvocationsForPrototype:prototype];
    
    // then
    expect([[handler.calls lastObject] prototype]).to.equal(prototype);
    expect([[handler.calls lastObject] invocations]).to.equal(invocationRecorder.recordedInvocations);
}

- (void)testThatVerifyDoesNotNotifyFinishOrFailureAfterSuccessInGroupMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(onFinishCalled).to.beFalsy();
    expect(onFailureCalled).to.beFalsy();
}

- (void)testThatVerifyNotifiesOnlyFailureAfterFailureInGroupMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(onFinishCalled).to.beFalsy();
    expect(onFailureCalled).to.beTruthy();
}

- (void)testThatVerifyDoesNotRemoveMatchingInvocationsAfterSuccessInGroupMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceedsWithMatches:[NSIndexSet indexSetWithIndex:1]]];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyDoesNotRemoveMatchingInvocationsAfterFailureInGroupMode {
    // given
    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithMatches:matches reason:nil]];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInGroupMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInGroupMode {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector collector]];
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}


#pragma mark - Test Finishing Group Mode

- (void)testThatFinishGroupPassesResultsToCollector {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collector];
    
    // begin the verification and make a few calls
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupVerification];
    
    // then
    expect(collector.collectedResults).to.equal(results);
}

- (void)testThatFinishGroupNotifiesOnlyFinishAfterSuccess {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collector];
    
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    // begin the verification and make a few calls
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWithResult:result]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupVerification];
    
    // then
    expect(onFinishCalled).to.beFalsy();
    expect(onFailureCalled).to.beTruthy();
}

- (void)testThatFinishGroupNotifiesFirstFailureThenFinishAfterFailure {
    // given
    MCKVerificationResult *failure = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSet]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:failure];
    
    NSMutableArray *calls = [NSMutableArray array];
    verifierDelegate.onFinish = ^{ [calls addObject:@"onFinish"]; };
    verifierDelegate.onFailure = ^(NSString *_){ [calls addObject:@"onFailure"]; };
    
    // begin the verification and make a few calls
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWithResult:result]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupVerification];
    
    // then
    expect(calls).to.equal(@[ @"onFailure", @"onFinish" ]);
}

- (void)testThatFinishGroupDoesNotRemoveMatchingInvocationsAfterSuccess {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // begin the verification and make a few calls
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWithResult:result]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupVerification];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatFinishGroupDoesNotRemoveMatchingInvocationsAfterFailure {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:[NSIndexSet indexSetWithIndex:1]];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // begin the verification and make a few calls
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    for (MCKVerificationResult *result in results) {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWithResult:result]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    }
    
    // when
    [verifier finishGroupVerification];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}


#pragma mark - Test Verification with Timeout

- (void)testThatVerifyCallsDelegateWhenProcessingTimeout {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    verifier.timeout = 0.1;
    
    __block BOOL willProcessCalled = NO; verifierDelegate.onWillProcessTimeout = ^{ willProcessCalled = YES; };
    __block BOOL didProcessCalled = NO; verifierDelegate.onDidProcessTimeout = ^{ didProcessCalled = YES; };
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(willProcessCalled).to.beTruthy();
    expect(didProcessCalled).to.beTruthy();
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessWithTimeout {
    // given
    __block BOOL shouldSucceed = NO;
    MCKVerificationResult *successResult = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    MCKVerificationResult *failureResult = [MCKVerificationResult failureWithReason:@"" matchingIndexes:[NSIndexSet indexSet]];
    
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    verifier.timeout = 1.0;
    
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWithImplementation:
                                      ^MCKVerificationResult *(MCKInvocationPrototype *p, NSArray *a) {
                                          return (shouldSucceed ? successResult : failureResult);
                                      }]];
    
    __block BOOL onFinishCalled = NO; verifierDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; verifierDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    
    // when
    [[AsyncService sharedService] callBlockDelayed:^{
        shouldSucceed = YES;
    }];
    
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(onFinishCalled).to.beTruthy();
    expect(onFailureCalled).to.beFalsy();
}

@end
