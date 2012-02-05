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
    id              sampleObject1;
    id              sampleObject2;
    id              sampleObject3;
}
@end


@implementation RGMockObjectTest

#pragma mark - Test Fixture

- (void)setUp {
    [super setUp];
    mockObject = [[RGMockRecorder alloc] init];
    sampleObject1 = @"<object1>";
    sampleObject2 = @"<object2>";
    sampleObject3 = @"<object3>";
}


#pragma mark - Test Recording

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


#pragma mark - Test Invocation Matching

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

- (void)testThatMatchingInvocationsMatchesEqualInvocationWithObjectArguments {
    // given
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(methodCallWithObject1:object2:object3:)];
    
    NSInvocation *sampleInvocation = [NSInvocation invocationWithMethodSignature:signature];
    sampleInvocation.selector = @selector(methodCallWithObject1:object2:object3:);
    sampleInvocation.target = mockObject;
    [sampleInvocation setArgument:&sampleObject1 atIndex:2];
    [sampleInvocation setArgument:&sampleObject2 atIndex:3];
    [sampleInvocation setArgument:&sampleObject3 atIndex:4];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(methodCallWithObject1:object2:object3:);
    invocation.target = mockObject;
    [invocation setArgument:&sampleObject1 atIndex:2];
    [invocation setArgument:&sampleObject2 atIndex:3];
    [invocation setArgument:&sampleObject3 atIndex:4];
    
    [mockObject mock_recordInvocation:invocation];
    
    // when
    NSArray *invocations = [mockObject mock_recordedInvocationsMatchingInvocation:sampleInvocation];
    
    // then
    STAssertEquals([invocations count], (NSUInteger)1, @"Wrong number of matching invocations");
    STAssertEqualObjects([invocations objectAtIndex:0], invocation, @"Wrong invocation at index 0");
}

- (void)testThatMatchingInvocationsMatchesEqualInvocationWithNilArguments {
    // given
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(methodCallWithObject1:object2:object3:)];
    sampleObject1 = sampleObject2 = sampleObject3 = nil;
    
    NSInvocation *sampleInvocation = [NSInvocation invocationWithMethodSignature:signature];
    sampleInvocation.selector = @selector(methodCallWithObject1:object2:object3:);
    sampleInvocation.target = mockObject;
    [sampleInvocation setArgument:&sampleObject1 atIndex:2];
    [sampleInvocation setArgument:&sampleObject2 atIndex:3];
    [sampleInvocation setArgument:&sampleObject3 atIndex:4];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(methodCallWithObject1:object2:object3:);
    invocation.target = mockObject;
    [invocation setArgument:&sampleObject1 atIndex:2];
    [invocation setArgument:&sampleObject2 atIndex:3];
    [invocation setArgument:&sampleObject3 atIndex:4];
    
    [mockObject mock_recordInvocation:invocation];
    
    // when
    NSArray *invocations = [mockObject mock_recordedInvocationsMatchingInvocation:sampleInvocation];
    
    // then
    STAssertEquals([invocations count], (NSUInteger)1, @"Wrong number of matching invocations");
    STAssertEqualObjects([invocations objectAtIndex:0], invocation, @"Wrong invocation at index 0");
}

- (void)testThatMatchingInvocationsDoesNotMatchEqualInvocationWithDifferentObjectArguments {
    // given
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(methodCallWithObject1:object2:object3:)];
    
    NSInvocation *sampleInvocation = [NSInvocation invocationWithMethodSignature:signature];
    sampleInvocation.selector = @selector(methodCallWithObject1:object2:object3:);
    sampleInvocation.target = mockObject;
    [sampleInvocation setArgument:&sampleObject1 atIndex:2];
    [sampleInvocation setArgument:&sampleObject2 atIndex:3];
    [sampleInvocation setArgument:&sampleObject3 atIndex:4];
    
    NSInvocation *invocation1 = [NSInvocation invocationWithMethodSignature:signature];
    invocation1.selector = @selector(methodCallWithObject1:object2:object3:);
    invocation1.target = mockObject;
    [invocation1 setArgument:&sampleObject3 atIndex:2];
    [invocation1 setArgument:&sampleObject2 atIndex:3];
    [invocation1 setArgument:&sampleObject1 atIndex:4];
    
    NSInvocation *invocation2 = [NSInvocation invocationWithMethodSignature:signature];
    invocation2.selector = @selector(methodCallWithObject1:object2:object3:);
    invocation2.target = mockObject;
    [invocation2 setArgument:&sampleObject2 atIndex:3];
    [invocation2 setArgument:&sampleObject1 atIndex:4];
    
    [mockObject mock_recordInvocation:invocation1];
    [mockObject mock_recordInvocation:invocation2];
    
    // when
    NSArray *invocations = [mockObject mock_recordedInvocationsMatchingInvocation:sampleInvocation];
    
    // then
    STAssertEquals([invocations count], (NSUInteger)0, @"No invocation should have matched");
}

@end
