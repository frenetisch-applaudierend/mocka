//
//  RGMockInvocationStubberTest.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockInvocationStubber.h"
#import "RGMockStubbing.h"
#import "BlockInvocationMatcher.h"
#import "BlockArgumentMatcher.h"
#import "MockTestObject.h"
#import "RGMockPerformBlockStubAction.h"
#import "NSInvocation+TestSupport.h"


@interface RGMockInvocationStubberTest : SenTestCase
@end

@implementation RGMockInvocationStubberTest {
    RGMockInvocationStubber *stubber;
    BlockInvocationMatcher  *invocationMatcher;
}

#pragma mark - Setup

- (void)setUp {
    stubber = [[RGMockInvocationStubber alloc] init];
}


#pragma mark - Test Creating Stubbings

- (void)testThatCreatingStubbingForInvocationCreatesStubbing {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber createStubbingForInvocation:invocation nonObjectArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.stubbings count], (NSUInteger)1, @"Stubbing was not created");
}

- (void)testThatCreatedStubbingForInvocationContainsInvocation {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber createStubbingForInvocation:invocation nonObjectArgumentMatchers:nil];
    
    // then
    RGMockStubbing *stubbing = [stubber.stubbings lastObject];
    STAssertEqualObjects([[stubbing.invocationPrototypes lastObject] invocation], invocation, @"Invocation was not added to stubbing");
}

- (void)testThatCreatedStubbingForInvocationContainsArgumentMatchers {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSArray *argumentMatchers = @[ [[BlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber createStubbingForInvocation:invocation nonObjectArgumentMatchers:argumentMatchers];
    
    // then
    RGMockStubbing *stubbing = [stubber.stubbings lastObject];
    STAssertEqualObjects([[stubbing.invocationPrototypes lastObject] nonObjectArgumentMatchers], argumentMatchers, @"Matchers were not added to stubbing");
}


#pragma mark - Test Continuous Stubbing

- (void)testThatCreatingStubbingForMultipleInvocationsCreatesOnlyOneStubbing {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber createStubbingForInvocation:invocation0 nonObjectArgumentMatchers:nil];
    [stubber createStubbingForInvocation:invocation1 nonObjectArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.stubbings count], (NSUInteger)1, @"Only one stubbing should have been created");
}

- (void)testThatAllCreatedStubbingsForMultipleInvocationsContainInvocation {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber createStubbingForInvocation:invocation0 nonObjectArgumentMatchers:nil];
    [stubber createStubbingForInvocation:invocation1 nonObjectArgumentMatchers:nil];
    
    // then
    RGMockStubbing *stubbing = [stubber.stubbings lastObject];
    STAssertEquals([stubbing.invocationPrototypes count], (NSUInteger)2, @"Not all invocations were added");
    STAssertEqualObjects([stubbing.invocationPrototypes[0] invocation], invocation0, @"Invocation was not added to stubbing");
    STAssertEqualObjects([stubbing.invocationPrototypes[1] invocation], invocation1, @"Invocation was not added to stubbing");
}

- (void)testThatAllCreatedStubbingsForMultipleInvocationsContainArgumentMatchers {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSArray *argumentMatchers0 = @[ [[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init] ];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithObjectParam1:intParam2:), nil, 0];
    NSArray *argumentMatchers1 = @[ [[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber createStubbingForInvocation:invocation0 nonObjectArgumentMatchers:argumentMatchers0];
    [stubber createStubbingForInvocation:invocation1 nonObjectArgumentMatchers:argumentMatchers1];
    
    // then
    RGMockStubbing *stubbing = [stubber.stubbings lastObject];
    STAssertEquals([stubbing.invocationPrototypes count], (NSUInteger)2, @"Not all invocations were added");
    STAssertEqualObjects([stubbing.invocationPrototypes[0] nonObjectArgumentMatchers], argumentMatchers0, @"Matchers were not added to stubbing");
    STAssertEqualObjects([stubbing.invocationPrototypes[1] nonObjectArgumentMatchers], argumentMatchers1, @"Matchers were not added to stubbing");
}

- (void)testThatAddingActionEndsMultipleStubbingMode {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber createStubbingForInvocation:invocation0 nonObjectArgumentMatchers:nil];
    [stubber addActionToCurrentStubbing:[RGMockPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber createStubbingForInvocation:invocation1 nonObjectArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.stubbings count], (NSUInteger)2, @"Two stubbing should have been created");
}

@end
