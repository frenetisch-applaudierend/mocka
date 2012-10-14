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
    BlockInvocationMatcher *invocationMatcher;
}

#pragma mark - Setup

- (void)setUp {
    invocationMatcher = [[BlockInvocationMatcher alloc] init];
    stubber = [[RGMockInvocationStubber alloc] initWithInvocationMatcher:invocationMatcher];
}


#pragma mark - Test Creating Stubs

- (void)testThatRecordingStubInvocationCreatesStub {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.recordedStubs count], (NSUInteger)1, @"Stubbing was not created");
}

- (void)testThatCreatedStubForInvocationContainsInvocation {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:nil];
    
    // then
    RGMockStub *stub = [stubber.recordedStubs lastObject];
    STAssertEqualObjects([[stub.invocationPrototypes lastObject] invocation], invocation, @"Invocation was not added to stub");
}

- (void)testThatCreatedStubForInvocationContainsArgumentMatchers {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSArray *argumentMatchers = @[ [[BlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    RGMockStub *stub = [stubber.recordedStubs lastObject];
    STAssertEqualObjects([[stub.invocationPrototypes lastObject] primitiveArgumentMatchers], argumentMatchers, @"Matchers were not added to stub");
}


#pragma mark - Test Group Invocation Recording

- (void)testThatRecordingMultipleStubInvocationsInRowCreatesOnlyOneStub {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:nil];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.recordedStubs count], (NSUInteger)1, @"Only one stub should have been created");
}

- (void)testThatCreatedStubForMultipleInvocationsContainsAllInvocations {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:nil];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:nil];
    
    // then
    RGMockStub *stub = [stubber.recordedStubs lastObject];
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
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:argumentMatchers0];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:argumentMatchers1];
    
    // then
    RGMockStub *stub = [stubber.recordedStubs lastObject];
    STAssertEquals([stub.invocationPrototypes count], (NSUInteger)2, @"Not all invocations were added");
    STAssertEqualObjects([stub.invocationPrototypes[0] primitiveArgumentMatchers], argumentMatchers0, @"Matchers were not added to stub");
    STAssertEqualObjects([stub.invocationPrototypes[1] primitiveArgumentMatchers], argumentMatchers1, @"Matchers were not added to stub");
}

- (void)testThatAfterAddingActionNewInvocationGroupStarts {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.recordedStubs count], (NSUInteger)2, @"Two stub should have been created");
}


#pragma mark - Test Querying for Stubs

- (void)testThatHasStubsReturnsNoIfNoStubsAreRecordedForInvocation {
    // given
    [stubber recordStubInvocation:[NSInvocation voidMethodInvocationForTarget:nil] withPrimitiveArgumentMatchers:nil];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return NO;
    }];
    
    // then
    MockTestObject *otherObject = [[MockTestObject alloc] init];
    NSInvocation *unrecordedInvocation = [NSInvocation voidMethodInvocationForTarget:otherObject];
    STAssertFalse([stubber hasStubsRecordedForInvocation:unrecordedInvocation], @"Should not have stubs for unrecorded invocation");
}

- (void)testThatHasStubsReturnsYesIfOneStubIsRecordedForInvocation {
    // given
    NSInvocation *recordedInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // then
    STAssertTrue([stubber hasStubsRecordedForInvocation:recordedInvocation], @"Should have stubs for recorded invocation");
}

- (void)testThatHasStubsReturnsYesIfManyStubsAreRecordedInOneGroupForInvocation {
    // given
    NSInvocation *recordedInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // then
    STAssertTrue([stubber hasStubsRecordedForInvocation:recordedInvocation], @"Should have stubs for recorded invocation");
}

- (void)testThatHasStubsReturnsYesIfManyStubsAreRecordedInManyGroupsForInvocation {
    // given
    NSInvocation *recordedInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // then
    STAssertTrue([stubber hasStubsRecordedForInvocation:recordedInvocation], @"Should have stubs for recorded invocation");
}


#pragma mark - Test Adding Actions

- (void)testThatAddingActionToStubAddsAction {
    // given
    [stubber recordStubInvocation:[NSInvocation voidMethodInvocationForTarget:nil] withPrimitiveArgumentMatchers:nil];
    id<RGMockStubAction> action = [RGMockPerformBlockStubAction performBlockActionWithBlock:nil];
    
    // when
    [stubber addActionToLastStub:action];
    
    // then
    NSArray *actions = [[stubber.recordedStubs lastObject] actions];
    STAssertEquals([actions count], (NSUInteger)1, @"Wrong number of actions recorded");
    STAssertEqualObjects([actions lastObject], action, @"Wrong action recorded");
}

- (void)testThatApplyingStubsToInvocationAppliesStubActionToAllMatchingInvocationsInOrder {
    // given
    NSInvocation *matchingInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSMutableArray *performedActions = [NSMutableArray array];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub1"];
    }]];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub2"];
    }]];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub3"];
    }]];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // when
    [stubber applyStubsForInvocation:matchingInvocation];
    
    // then
    STAssertEqualObjects(performedActions, (@[ @"stub1", @"stub2", @"stub3" ]), @"Performed actions were not recorded in correct order");
}

- (void)testThatApplyingStubsToInvocationDoesNotApplyStubActionToNonMatchingInvocation {
    // given
    NSInvocation *matchingInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *nonMatchingInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSMutableArray *performedActions = [NSMutableArray array];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub1"];
    }]];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub2"];
    }]];
    
    [stubber recordStubInvocation:nonMatchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"NON MATCHING INVOCATION"];
    }]];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // when
    [stubber applyStubsForInvocation:matchingInvocation];
    
    // then
    STAssertEqualObjects(performedActions, (@[ @"stub1", @"stub2" ]), @"Performed actions were not recorded in correct order");
}

@end
