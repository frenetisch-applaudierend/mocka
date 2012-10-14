//
//  RGMockInvocationStubberTest.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockInvocationStubber.h"
#import "RGMockStub.h"
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


#pragma mark - Test Creating Stubs

- (void)testThatRecordingStubInvocationCreatesStub {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber recordStubInvocation:invocation withNonObjectArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.stubs count], (NSUInteger)1, @"Stubbing was not created");
}

- (void)testThatCreatedStubForInvocationContainsInvocation {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber recordStubInvocation:invocation withNonObjectArgumentMatchers:nil];
    
    // then
    RGMockStub *stub = [stubber.stubs lastObject];
    STAssertEqualObjects([[stub.invocationPrototypes lastObject] invocation], invocation, @"Invocation was not added to stub");
}

- (void)testThatCreatedStubForInvocationContainsArgumentMatchers {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSArray *argumentMatchers = @[ [[BlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber recordStubInvocation:invocation withNonObjectArgumentMatchers:argumentMatchers];
    
    // then
    RGMockStub *stub = [stubber.stubs lastObject];
    STAssertEqualObjects([[stub.invocationPrototypes lastObject] nonObjectArgumentMatchers], argumentMatchers, @"Matchers were not added to stub");
}


#pragma mark - Test Group Invocation Recording

- (void)testThatRecordingMultipleStubInvocationsInRowCreatesOnlyOneStub {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withNonObjectArgumentMatchers:nil];
    [stubber recordStubInvocation:invocation1 withNonObjectArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.stubs count], (NSUInteger)1, @"Only one stub should have been created");
}

- (void)testThatCreatedStubForMultipleInvocationsContainsAllInvocations {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withNonObjectArgumentMatchers:nil];
    [stubber recordStubInvocation:invocation1 withNonObjectArgumentMatchers:nil];
    
    // then
    RGMockStub *stub = [stubber.stubs lastObject];
    STAssertEquals([stub.invocationPrototypes count], (NSUInteger)2, @"Not all invocations were added");
    STAssertEqualObjects([stub.invocationPrototypes[0] invocation], invocation0, @"Invocation was not added to stub");
    STAssertEqualObjects([stub.invocationPrototypes[1] invocation], invocation1, @"Invocation was not added to stub");
}

- (void)testThatCreatedStubForMultipleInvocationsContainsAllArgumentMatchers {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSArray *argumentMatchers0 = @[ [[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init] ];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithObjectParam1:intParam2:), nil, 0];
    NSArray *argumentMatchers1 = @[ [[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber recordStubInvocation:invocation0 withNonObjectArgumentMatchers:argumentMatchers0];
    [stubber recordStubInvocation:invocation1 withNonObjectArgumentMatchers:argumentMatchers1];
    
    // then
    RGMockStub *stub = [stubber.stubs lastObject];
    STAssertEquals([stub.invocationPrototypes count], (NSUInteger)2, @"Not all invocations were added");
    STAssertEqualObjects([stub.invocationPrototypes[0] nonObjectArgumentMatchers], argumentMatchers0, @"Matchers were not added to stub");
    STAssertEqualObjects([stub.invocationPrototypes[1] nonObjectArgumentMatchers], argumentMatchers1, @"Matchers were not added to stub");
}

- (void)testThatGroupInvocationRecordingEndsWhenAddingAction {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withNonObjectArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubInvocation:invocation1 withNonObjectArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.stubs count], (NSUInteger)2, @"Two stub should have been created");
}

@end
