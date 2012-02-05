//
//  RGMockVerifierTest.m
//  rgmock
//
//  Created by Markus Gasser on 31.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockVerifier.h"
#import "RGClassMockRecorder.h"
#import "MockTestObject.h"


@interface RGMockVerifierTest : SenTestCase
@end


@implementation RGMockVerifierTest

#pragma mark - Test Verification

- (void)testThatVerifierSucceedsWhenReplayingRecordedSimpleMethodCall {
    // given
    RGMockRecorder *recorder = [[RGClassMockRecorder alloc] initWithClass:[MockTestObject class]];
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethod)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethod);
    invocation.target = recorder;
    
    // when
    [recorder mock_recordInvocation:invocation];
    RGMockVerifier *verifier = [[RGMockVerifier alloc] initWithRecorder:recorder];
    
    // then
    STAssertNoThrow([(id)verifier simpleMethod], @"Verifier should succeed for recorded invocation");
}

- (void)testThatVerifierFailsForNonRecordedSimpleMethodCall {
    // given
    RGMockRecorder *recorder = [[RGClassMockRecorder alloc] initWithClass:[MockTestObject class]];
    RGMockVerifier *verifier = [[RGMockVerifier alloc] initWithRecorder:recorder];
    
    // then
    STAssertThrowsSpecificNamed([(id)verifier simpleMethod],
                                NSException, SenTestFailureException,
                                @"Verifier should have failed as a test failure");
}

@end
