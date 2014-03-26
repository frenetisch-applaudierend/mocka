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

@end
