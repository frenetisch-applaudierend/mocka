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
    FakeMockingContext *mockingContext;
}

- (void)setUp {
    mockingContext = [FakeMockingContext fakeContext];
    
    mockingContext.shouldIgnoreFailures = YES;
    
    mockingContext.invocationRecorder = [[MCKInvocationRecorder alloc] initWithMockingContext:mockingContext];
    [mockingContext.invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [mockingContext.invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [mockingContext.invocationRecorder appendInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    
    verifier = [[MCKInvocationVerifier alloc] initWithMockingContext:mockingContext];
    
    mockingContext.invocationVerifier = verifier;
}

- (FakeVerificationHandler *)verificationHandlerWhichFailsUnless:(BOOL(^)(void))condition {
    return [FakeVerificationHandler handlerWithImplementation:^MCKVerificationResult*(MCKInvocationPrototype *p, NSArray *a) {
        return (condition()
                ? [MCKVerificationResult successWithMatchingIndexes:nil]
                : [MCKVerificationResult failureWithReason:nil matchingIndexes:nil]);
    }];
}


#pragma mark - Test General Usage

- (void)testThatIfNoHandlerIsSetTheDefaultHandlerIsUsed {
    // given
    [verifier beginVerificationWithCollector:[FakeVerificationResultCollector dummy]];
    
    // then
    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatUsingAnotherHandlerWillSetThisHandler {
    // given
    [verifier beginVerificationWithCollector:[FakeVerificationResultCollector dummy]];
    
    // when
    FakeVerificationHandler *handler = [FakeVerificationHandler dummy];
    [verifier useVerificationHandler:handler];
    
    // then
    expect(verifier.verificationHandler).to.equal(handler);
}

- (void)testThatUsingMultipleHandlersWillSetLastHandler {
    // given
    [verifier beginVerificationWithCollector:[FakeVerificationResultCollector dummy]];
    
    // when
    [verifier useVerificationHandler:[FakeVerificationHandler dummy]];
    [verifier useVerificationHandler:[FakeVerificationHandler dummy]];
    
    FakeVerificationHandler *usedHandler = [FakeVerificationHandler dummy];
    [verifier useVerificationHandler:usedHandler];
    
    // then
    expect(verifier.verificationHandler).to.equal(usedHandler);
}


#pragma mark - Calling and Verifying

- (void)testThatVerifyInvocationsVerifiesUsingPassedHandler {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype dummy];
    
    // when
    [verifier beginVerificationWithCollector:[FakeVerificationResultCollector dummy]];
    [verifier useVerificationHandler:handler];
    [verifier verifyInvocationsForPrototype:prototype];
    [verifier finishVerification];
    
    // then
    expect([[handler.calls lastObject] prototype]).to.equal(prototype);
}

//- (void)testThatVerifyInvocationsVerifiesRecorderInvocations {
//    // given
//    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
//    
//    // when
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
//        [verifier useVerificationHandler:handler];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//        [verifier useVerificationHandler:handler];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//    };
//    [verifier finishGroupVerification];
//    
//    // then
//    expect([[handler.calls lastObject] invocations]).to.equal(mockingContext.invocationRecorder.recordedInvocations);
//}

//- (void)testThatVerifyDoesNotRemovesAnyInvocationsAfterSuccess {
//    // given
//    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
//    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:matches];
//    NSArray *expectedRemainingInvocations = mockingContext.invocationRecorder.recordedInvocations;
//    
//    // when
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
//        [verifier useVerificationHandler:handler];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//    };
//    [verifier finishGroupVerification];
//    
//    // then
//    expect(mockingContext.invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
//}

//- (void)testThatVerifyDoesNotRemoveAnyInvocationsAfterFailure {
//    // given
//    NSIndexSet *matches = [NSIndexSet indexSetWithIndex:1];
//    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichFailsWithMatches:matches reason:nil];
//    NSArray *expectedRemainingInvocations = mockingContext.invocationRecorder.recordedInvocations;
//    
//    // when
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
//        [verifier useVerificationHandler:handler];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//    };
//    [verifier finishGroupVerification];
//    
//    // then
//    expect(mockingContext.invocationRecorder.recordedInvocations).to.equal(expectedRemainingInvocations);
//}

//- (void)testThatVerifyResetsHandlerToDefaultAfterEachSuccessfulVerify {
//    // when
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
//        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
//        
//        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
//    };
//    [verifier finishGroupVerification];
//    
//    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
//}

//- (void)testThatVerifyResetsHandlerToDefaultAfterFailure {
//    // when
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier startGroupVerificationWithCollector:[FakeVerificationResultCollector dummy]]; {
//        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
//        
//        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//        expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
//    };
//    [verifier finishGroupVerification];
//    
//    expect(verifier.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
//}


#pragma mark - Collector Interaction

//- (void)testThatStartGroupVerificationCallsBeginCollectingOnCollector {
//    // given
//    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector dummy];
//    
//    // when
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier startGroupVerificationWithCollector:collector];
//    
//    // then
//    expect(collector.invocationRecorder).to.equal(mockingContext.invocationRecorder);
//}

//- (void)testThatVerifyPassesResultToCollector {
//    // given
//    FakeVerificationResultCollector *collector = [FakeVerificationResultCollector dummy];
//    
//    // when
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier startGroupVerificationWithCollector:collector]; {
//        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//        [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichFailsWithReason:nil]];
//        [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//    };
//    [verifier finishGroupVerification];
//    
//    // then
//    expect(collector.collectedResults).to.equal(@[
//        [MCKVerificationResult successWithMatchingIndexes:nil],
//        [MCKVerificationResult failureWithReason:nil matchingIndexes:nil],
//    ]);
//}


#pragma mark - Test Verification with Timeout

//- (void)testThatTimeoutIsResetAfterProcessingOneCall {
//    // given
//    [verifier beginVerificationWithInvocationRecorder:mockingContext.invocationRecorder];
//    [verifier useVerificationHandler:[FakeVerificationHandler handlerWhichSucceeds]];
//    verifier.timeout = 1.0;
//    
//    // when
//    [verifier verifyInvocationsForPrototype:[FakeInvocationPrototype dummy]];
//    
//    // then
//    expect(verifier.timeout).to.equal(0.0);
//}

@end
