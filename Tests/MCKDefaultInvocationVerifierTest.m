//
//  MCKDefaultInvocationVerifierTest.m
//  mocka
//
//  Created by Markus Gasser on 01.11.12.
//  Copyright 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKDefaultInvocationVerifier.h"

#import "CannedVerificationHandler.h"
#import "NSInvocation+TestSupport.h"


@interface MCKDefaultInvocationVerifierTest : SenTestCase
@end


@implementation MCKDefaultInvocationVerifierTest {
    MCKDefaultInvocationVerifier *verifier;
}

#pragma mark - Setup

- (void)setUp {
    verifier = [[MCKDefaultInvocationVerifier alloc] init];
}

#pragma mark - Test Cases

- (void)testThatNextContetModeIsRecording {
    STAssertEquals([verifier nextContextMode], MCKContextModeRecording, @"Wrong context mode returned");
}

- (void)testThatVerifyCallsVerificationHandler {
    // given
    CannedVerificationHandler *handler = [[CannedVerificationHandler alloc] init];
    verifier.verificationHandler = handler;
    
    // when
    [verifier verifyInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]
                    inRecorder:nil failureHandler:nil];
    
    // then
    STAssertEquals([(CannedVerificationHandler *)verifier.verificationHandler numberOfCalls], (NSUInteger)1, @"Number of calls is wrong");
}

@end
