//
//  MCKInvocationVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestingSupport.h"

#import "MCKInvocationVerifier.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"


@interface MCKInvocationVerifierTest : XCTestCase @end
@implementation MCKInvocationVerifierTest {
    MCKInvocationVerifier *verifier;
    MCKInvocationRecorder *invocationRecorder;
    BlockInvocationVerifierDelegate *verifierDelegate;
    NSMutableArray *delegateCallSequence;
}

- (void)setUp {
    __weak typeof(self) weakSelf = self;
    
    delegateCallSequence = [NSMutableArray array];
    
    verifierDelegate = [[BlockInvocationVerifierDelegate alloc] init];
    verifierDelegate.onFinish = ^{
        __strong typeof (weakSelf) self = weakSelf;
        [self->delegateCallSequence addObject:@"onFinish"];
    };
    verifierDelegate.onFailure = ^ (NSString *_) {
        __strong typeof (weakSelf) self = weakSelf;
        [self->delegateCallSequence addObject:@"onFailure"];
    };
    verifierDelegate.onWillProcessTimeout = ^{
        __strong typeof (weakSelf) self = weakSelf;
        [self->delegateCallSequence addObject:@"onWillProcessTimeout"];
    };
    verifierDelegate.onDidProcessTimeout = ^{
        __strong typeof (weakSelf) self = weakSelf;
        [self->delegateCallSequence addObject:@"onDidProcessTimeout"];
    };
    
    invocationRecorder = [[MCKInvocationRecorder alloc] init];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    
    verifier = [[MCKInvocationVerifier alloc] init];
    verifier.delegate = verifierDelegate;
}

- (FakeVerificationHandler *)verificationHandlerWhichFailsUnless:(BOOL(^)(void))condition {
    return [FakeVerificationHandler handlerWithImplementation:^MCKVerificationResult*(MCKInvocationPrototype *p, NSArray *a) {
        return (condition()
                ? [MCKVerificationResult successWithMatchingIndexes:nil]
                : [MCKVerificationResult failureWithReason:nil matchingIndexes:nil]);
    }];
}


@end


#pragma mark - Test General Usage
@implementation MCKInvocationVerifierTest (GeneralSetup)

- (void)testThatIfNoHandlerIsSetTheDefaultHandlerIsUsed {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatUsingAnotherHandlerWillSetThisHandler {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    
    // when
    FakeVerificationHandler *handler = [FakeVerificationHandler dummy];
    [verifier useVerificationHandler:handler];
    
    // then
    expect(verifier.verificationHandler).to.equal(handler);
}

- (void)testThatUsingMultipleHandlersWillSetLastHandler {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    
    // when
    [verifier useVerificationHandler:[FakeVerificationHandler dummy]];
    [verifier useVerificationHandler:[FakeVerificationHandler dummy]];
    
    FakeVerificationHandler *usedHandler = [FakeVerificationHandler dummy];
    [verifier useVerificationHandler:usedHandler];
    
    // then
    expect(verifier.verificationHandler).to.equal(usedHandler);
}

@end


#pragma mark - Test Verification in Single Call Mode
@implementation MCKInvocationVerifierTest (SingleCallMode)

// Single call mode flow:
//
// 1 call to  -[MCKInvocationVerifier beginVerificationWithInvocationRecorder:]
// N calls to -[MCKInvocationVerifier useVerificationHandler:]
// 1 call to  -[MCKInvocationVerifier verifyInvocationsForPrototype:]
//


#pragma mark - Calling and Verifying

- (void)testThatVerifyInvocationsVerifiesUsingPassedHandlerInSingleCallMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype dummy];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:handler];
    [verifier verifyInvocationsForPrototype:prototype];
    
    // then
    expect([[handler.calls lastObject] prototype]).to.equal(prototype);
}

- (void)testThatVerifyInvocationsVerifiesRecorderInvocationsInSingleCallMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:handler];
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect([[handler.calls lastObject] invocations]).to.equal(invocationRecorder.recordedInvocations);
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterSuccessInSingleCallMode {
    // given
    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
    NSArray *expectedRemainingInvocations = @[
        [invocationRecorder invocationAtIndex:0], [invocationRecorder invocationAtIndex:2]
    ];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceedsWithMatches:matches]];
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterFailureInSingleCallMode {
    // given
    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
    NSArray *expectedRemainingInvocations = @[
        [invocationRecorder invocationAtIndex:0], [invocationRecorder invocationAtIndex:2]
    ];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithMatches:matches reason:nil]];
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInSingleCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInSingleCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}


#pragma mark - Notifications

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessInSingleCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onFinish" ]);
}

- (void)testThatVerifyNotifiesFirstFailureThenFinishAfterFailureInSingleCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onFailure", @"onFinish" ]);
}

@end


#pragma mark - Test Verification in Group Call Mode
@implementation MCKInvocationVerifierTest (GroupCallMode)

// Group call mode flow:
//
// 1 call to  -[MCKInvocationVerifier beginVerificationWithInvocationRecorder:]
// 1 call to  -[MCKInvocationVerifier startGroupVerificationWithCollector:]
// N sequences of
//     N calls to -[MCKInvocationVerifier useVerificationHandler:]
//     1 call to -[MCKInvocationVerifier verifyInvocationsForPrototype:]
// 1 call to  -[MCKInvocationVerifier finishGroupVerification]
//


#pragma mark - Calling and Verifying

- (void)testThatVerifyInvocationsVerifiesUsingPassedHandlerInGroupCallMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype dummy];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:handler];
        [verifier verifyInvocationsForPrototype:prototype];
    };
    [verifier finishGroupVerification];
    
    // then
    expect([[handler.calls lastObject] prototype]).to.equal(prototype);
}

- (void)testThatVerifyInvocationsVerifiesRecorderInvocationsInGroupCallMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:handler];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        [verifier useVerificationHandler:handler];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    };
    [verifier finishGroupVerification];
    
    // then
    expect([[handler.calls lastObject] invocations]).to.equal(invocationRecorder.recordedInvocations);
}

- (void)testThatVerifyDoesNotRemovesAnyInvocationsAfterSuccessInGroupCallMode {
    // given
    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:matches];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:handler];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    };
    [verifier finishGroupVerification];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyDoesNotRemoveAnyInvocationsAfterFailureInGroupCallMode {
    // given
    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichFailsWithMatches:matches reason:nil];
    NSArray *expectedRemainingInvocations = invocationRecorder.recordedInvocations;
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:handler];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    };
    [verifier finishGroupVerification];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterEachSuccessfulVerifyInGroupCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
        
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
    };
    [verifier finishGroupVerification];
    
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInGroupCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
        
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
    };
    [verifier finishGroupVerification];
    
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}


#pragma mark - Notifications

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessInGroupCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    };
    [verifier finishGroupVerification];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onFinish" ]);
}

- (void)testThatVerifyNotifiesFailuresForFailingVerificationsThenFinishAfterVerificationFailureInGroupCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    };
    [verifier finishGroupVerification];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onFailure", @"onFailure", @"onFinish" ]);
}

- (void)testThatVerifyNotifiesFirstFailureThenFinishAfterSuccessAndFailureInGroupCallMode {
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
        // first call succeeds
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        
        // second call fails
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    };
    [verifier finishGroupVerification];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onFailure", @"onFinish" ]);
}



#pragma mark - Collector Interaction

- (void)testThatStartGroupVerificationCallsBeginCollectingOnCollector {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector dummy];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    
    // then
    expect(collector.invocationRecorder).to.equal(invocationRecorder);
}

- (void)testThatVerifyPassesResultToCollector {
    // given
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector dummy];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector]; {
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    };
    [verifier finishGroupVerification];
    
    // then
    expect(collector.collectedResults).to.equal(@[
        [MCKVerificationResult successWithMatchingIndexes:nil],
        [MCKVerificationResult failureWithReason:nil matchingIndexes:nil],
    ]);
}

- (void)testThatFinishGroupNotifiesFinishForSuccessfulCollectorResultInGroupCallMode {
    // given
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:nil];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    [verifier finishGroupVerification];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onFinish" ]);
}

- (void)testThatFinishGroupNotifiesFailureForFailingCollectorResultInGroupCallMode {
    // given
    MCKVerificationResult *result = [MCKVerificationResult failureWithReason:nil matchingIndexes:nil];
    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector collectorWithMergedResult:result];
    
    // when
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier startGroupVerificationWithCollector:collector];
    [verifier finishGroupVerification];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onFailure", @"onFinish" ]);
}

@end


#pragma mark - Test Verification with Timeout
@implementation MCKInvocationVerifierTest (Timeout)

- (void)testThatVerifyCallsDelegateWhenProcessingTimeout {
    // given
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
    verifier.timeout = 0.1;
    
    // when
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    NSIndexSet *firstTwo = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
    expect([delegateCallSequence objectsAtIndexes:firstTwo]).to.equal(@[ @"onWillProcessTimeout", @"onDidProcessTimeout" ]);
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessWithTimeout {
    // given
    __block BOOL shouldSucceed = NO;
    
    [verifier beginVerificationWithInvocationRecorder:invocationRecorder];
    verifier.timeout = 1.0;
    [verifier useVerificationHandler:[self verificationHandlerWhichFailsUnless:^BOOL{
        return shouldSucceed;
    }]];
    
    // when
    [[AsyncService sharedService] callBlockDelayed:^{
        shouldSucceed = YES;
    }];
    
    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    expect(delegateCallSequence).to.equal(@[ @"onWillProcessTimeout", @"onDidProcessTimeout", @"onFinish" ]);
}

@end
