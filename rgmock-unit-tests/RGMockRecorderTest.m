//
//  RGMockObjectTest.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockRecorder.h"
#import "MockTestObject.h"
#import "RGMockInvocationMatcherFake.h"


@interface RGMockRecorderTest : SenTestCase {
@private
    RGMockRecorder *mockObject;
    id              sampleObject1;
    id              sampleObject2;
    id              sampleObject3;
}
@end


@implementation RGMockRecorderTest

#pragma mark - Test Fixture

- (void)setUp {
    [super setUp];
    mockObject = [[RGMockRecorder alloc] init];
    sampleObject1 = @"<object1>";
    sampleObject2 = @"<object2>";
    sampleObject3 = @"<object3>";
}


#pragma mark - Test Invocation Recording

- (void)testThatRecordedInvocationsContainsInvocationAfterRecording {
    // given
    id invocation = @"<invocation>";
    
    // when
    [mockObject mock_recordInvocation:invocation];
    
    // then
    STAssertTrue([[mockObject mock_recordedInvocations] containsObject:invocation], @"Invocation was not recorded");
}

- (void)testThatForwardInvocationRecordsInvocation {
    // given
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethodCall)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethodCall);
    invocation.target = mockObject;
    
    // when
    [mockObject forwardInvocation:invocation];
    
    // then
    STAssertTrue([[mockObject mock_recordedInvocations] containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Matching

- (void)testThatMatchingInvocationsReturnsInvocationsThatMatch {
    // given
    MockTestObject *testObject = [[MockTestObject alloc] init];
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethodCall)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethodCall);
    invocation.target = testObject;
    
    NSInvocation *matchingInvocation1 = [NSInvocation invocationWithMethodSignature:signature];
    matchingInvocation1.selector = @selector(simpleMethodCall);
    matchingInvocation1.target = testObject;
    
    NSInvocation *matchingInvocation2 = [NSInvocation invocationWithMethodSignature:signature];
    matchingInvocation2.selector = @selector(simpleMethodCall);
    matchingInvocation2.target = testObject;
    
    // when
    RGMockInvocationMatcherFake *matcher = [[RGMockInvocationMatcherFake alloc] init];
    [matcher fake_shouldMatchInvocation:invocation withInvocation:matchingInvocation1];
    [matcher fake_shouldMatchInvocation:invocation withInvocation:matchingInvocation2];
    
    RGMockRecorder *recorder = [[RGMockRecorder alloc] initWithInvocationMatcher:matcher];
    [recorder mock_recordInvocation:matchingInvocation1];
    [recorder mock_recordInvocation:matchingInvocation2];
    
    // then
    NSArray *matchingInvocations = [recorder mock_recordedInvocationsMatchingInvocation:invocation];
    STAssertEqualObjects(matchingInvocations, ([NSArray arrayWithObjects:matchingInvocation1, matchingInvocation2, nil]),
                         @"Wrong matching invocations");
}

- (void)testThatMatchingInvocationsDoesNotReturnInvocationsThatDontMatch {
    // given
    MockTestObject *testObject = [[MockTestObject alloc] init];
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethodCall)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethodCall);
    invocation.target = testObject;
    
    NSInvocation *matchingInvocation = [NSInvocation invocationWithMethodSignature:signature];
    matchingInvocation.selector = @selector(simpleMethodCall);
    matchingInvocation.target = testObject;
    
    NSInvocation *nonMatchingInvocation = [NSInvocation invocationWithMethodSignature:signature];
    nonMatchingInvocation.selector = @selector(simpleMethodCall);
    nonMatchingInvocation.target = nil;
    
    // when
    RGMockInvocationMatcherFake *matcher = [[RGMockInvocationMatcherFake alloc] init];
    [matcher fake_shouldMatchInvocation:invocation withInvocation:matchingInvocation];
    // nonMatchingInvocation should not match
    
    RGMockRecorder *recorder = [[RGMockRecorder alloc] initWithInvocationMatcher:matcher];
    [recorder mock_recordInvocation:matchingInvocation];
    [recorder mock_recordInvocation:nonMatchingInvocation];
    
    // then
    NSArray *matchingInvocations = [recorder mock_recordedInvocationsMatchingInvocation:invocation];
    STAssertEqualObjects(matchingInvocations, ([NSArray arrayWithObject:matchingInvocation]),
                         @"Wrong matching invocations");
}


@end
