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


@interface RGMockObjectTest : SenTestCase {
@private
    RGMockRecorder *mockObject;
}
@end


@implementation RGMockObjectTest

#pragma mark - Test Fixture

- (void)setUp {
    [super setUp];
    mockObject = [[RGMockRecorder alloc] init];
}


#pragma mark - Test Cases

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
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethod)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethod);
    invocation.target = mockObject;
    
    // when
    [mockObject forwardInvocation:invocation];
    
    // then
    STAssertTrue([[mockObject mock_recordedInvocations] containsObject:invocation], @"Invocation was not recorded");
}

- (void)testThatMatchingInvocationsMatchesEqualInvocationsWithoutArguments {
    // given
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethod)];
    
    NSInvocation *sampleInvocation = [NSInvocation invocationWithMethodSignature:signature];
    sampleInvocation.selector = @selector(simpleMethod);
    sampleInvocation.target = mockObject;
    
    NSInvocation *invocation1 = [NSInvocation invocationWithMethodSignature:signature];
    invocation1.selector = @selector(simpleMethod);
    invocation1.target = mockObject;
    
    NSInvocation *invocation2 = [NSInvocation invocationWithMethodSignature:signature];
    invocation2.selector = @selector(simpleMethod);
    invocation2.target = mockObject;
    
    [mockObject mock_recordInvocation:invocation1];
    [mockObject mock_recordInvocation:invocation2];
    
    // when
    NSArray *invocations = [mockObject mock_recordedInvocationsMatchingInvocation:sampleInvocation];
    
    // then
    STAssertEquals([invocations count], (NSUInteger)2, @"Wrong number of matching invocations");
    STAssertEqualObjects([invocations objectAtIndex:0], invocation1, @"Wrong invocation at index 0");
    STAssertEqualObjects([invocations objectAtIndex:1], invocation2, @"Wrong invocation at index 1");
}

- (void)testThatMatchingInvocationsDoesNotMatchNonEqualInvocationsWithoutArguments {
    // given
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethod)];
    
    NSInvocation *sampleInvocation = [NSInvocation invocationWithMethodSignature:signature];
    sampleInvocation.selector = @selector(simpleMethod);
    sampleInvocation.target = nil;
    
    NSInvocation *invocation1 = [NSInvocation invocationWithMethodSignature:signature];
    invocation1.selector = @selector(simpleMethod);
    invocation1.target = mockObject;
    
    NSInvocation *invocation2 = [NSInvocation invocationWithMethodSignature:signature];
    invocation2.selector = @selector(simpleMethod);
    invocation2.target = mockObject;
    
    [mockObject mock_recordInvocation:invocation1];
    [mockObject mock_recordInvocation:invocation2];
    
    // when
    NSArray *invocations = [mockObject mock_recordedInvocationsMatchingInvocation:sampleInvocation];
    
    // then
    STAssertEquals([invocations count], (NSUInteger)0, @"Wrong number of matching invocations");
}

@end
