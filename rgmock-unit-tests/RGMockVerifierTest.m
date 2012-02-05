//
//  RGMockVerifierTest.m
//  rgmock
//
//  Created by Markus Gasser on 31.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockVerifier.h"
#import "RGMockRecorderFake.h"
#import "RGMockClassRecorder.h"
#import "MockTestObject.h"


@interface RGMockVerifierTest : SenTestCase
@end


@implementation RGMockVerifierTest

#pragma mark - Test Verification

- (void)testThatVerifierSucceedsForRecordedMethodCall {
    // given
    RGMockRecorderFake *recorder = [RGMockRecorderFake fakeWithRealRecorder:[[RGMockClassRecorder alloc] initWithClass:MockTestObject.class]];
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethodCall)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethodCall);
    invocation.target = recorder;
    
    // when
    [recorder fake_shouldMatchInvocation:invocation];
    
    // then
    RGMockVerifier *verifier = [[RGMockVerifier alloc] initWithRecorder:recorder];
    STAssertNoThrow([(id)verifier simpleMethodCall], @"Verifier should succeed for recorded invocation");
}

- (void)testThatVerifierFailsForNonRecordedMethodCall {
    // given
    RGMockRecorderFake *recorder = [RGMockRecorderFake fakeWithRealRecorder:[[RGMockClassRecorder alloc] initWithClass:MockTestObject.class]];
    RGMockVerifier *verifier = [[RGMockVerifier alloc] initWithRecorder:recorder];
    
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethodCall)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethodCall);
    invocation.target = recorder;
    
    // when
    [recorder fake_shouldNotMatchInvocation:invocation];
    
    // then
    STAssertThrowsSpecificNamed([(id)verifier simpleMethodCall],
                                NSException, SenTestFailureException,
                                @"Verifier should have failed as a test failure");
}

@end
