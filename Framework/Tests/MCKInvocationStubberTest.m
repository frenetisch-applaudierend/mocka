//
//  MCKInvocationStubberTest.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKInvocationStubber.h"
#import "MCKStub.h"
#import "MCKPerformBlockStubAction.h"

#import "NSInvocation+TestSupport.h"
#import "TestObject.h"
#import "BlockInvocationMatcher.h"
#import "MCKBlockArgumentMatcher.h"


@interface MCKInvocationStubberTest : XCTestCase
@end

@implementation MCKInvocationStubberTest {
    MCKInvocationStubber *stubber;
    BlockInvocationMatcher *invocationMatcher;
}

#pragma mark - Setup

- (void)setUp {
    invocationMatcher = [[BlockInvocationMatcher alloc] init];
    stubber = [[MCKInvocationStubber alloc] initWithInvocationMatcher:invocationMatcher];
}


#pragma mark - Test Creating Stubs

- (void)testThatRecordingStubInvocationCreatesStub {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:nil];
    
    // then
    XCTAssertEqual([stubber.recordedStubs count], (NSUInteger)1, @"Stubbing was not created");
}

- (void)testThatCreatedStubForInvocationContainsInvocation {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:nil];
    
    // then
    MCKStub *stub = [stubber.recordedStubs lastObject];
    XCTAssertEqualObjects([[stub.invocationPrototypes lastObject] invocation], invocation, @"Invocation was not added to stub");
}

- (void)testThatCreatedStubForInvocationContainsArgumentMatchers {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSArray *argumentMatchers = @[ [[MCKBlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    MCKStub *stub = [stubber.recordedStubs lastObject];
    XCTAssertEqualObjects([[stub.invocationPrototypes lastObject] primitiveArgumentMatchers], argumentMatchers, @"Matchers were not added to stub");
}


#pragma mark - Test Group Invocation Recording

- (void)testThatRecordingMultipleStubInvocationsInRowCreatesOnlyOneStub {
    // given
    TestObject *object = [[TestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:nil];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:nil];
    
    // then
    XCTAssertEqual([stubber.recordedStubs count], (NSUInteger)1, @"Only one stub should have been created");
}

- (void)testThatCreatedStubForMultipleInvocationsContainsAllInvocations {
    // given
    TestObject *object = [[TestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:nil];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:nil];
    
    // then
    MCKStub *stub = [stubber.recordedStubs lastObject];
    XCTAssertEqual([stub.invocationPrototypes count], (NSUInteger)2, @"Not all invocations were added");
    XCTAssertEqualObjects([stub.invocationPrototypes[0] invocation], invocation0, @"Invocation was not added to stub");
    XCTAssertEqualObjects([stub.invocationPrototypes[1] invocation], invocation1, @"Invocation was not added to stub");
}

- (void)testThatCreatedStubForMultipleInvocationsContainsAllArgumentMatchers {
    // given
    TestObject *object = [[TestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSArray *argumentMatchers0 = @[ [[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init] ];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithObjectParam1:intParam2:), nil, 0];
    NSArray *argumentMatchers1 = @[ [[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:argumentMatchers0];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:argumentMatchers1];
    
    // then
    MCKStub *stub = [stubber.recordedStubs lastObject];
    XCTAssertEqual([stub.invocationPrototypes count], (NSUInteger)2, @"Not all invocations were added");
    XCTAssertEqualObjects([stub.invocationPrototypes[0] primitiveArgumentMatchers], argumentMatchers0, @"Matchers were not added to stub");
    XCTAssertEqualObjects([stub.invocationPrototypes[1] primitiveArgumentMatchers], argumentMatchers1, @"Matchers were not added to stub");
}

- (void)testThatAfterAddingActionNewInvocationGroupStarts {
    // given
    TestObject *object = [[TestObject alloc] init];
    NSInvocation *invocation0 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *invocation1 = [NSInvocation invocationForTarget:object selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    [stubber recordStubInvocation:invocation0 withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubInvocation:invocation1 withPrimitiveArgumentMatchers:nil];
    
    // then
    XCTAssertEqual([stubber.recordedStubs count], (NSUInteger)2, @"Two stub should have been created");
}


#pragma mark - Test Querying for Stubs

- (void)testThatHasStubsReturnsNoIfNoStubsAreRecordedForInvocation {
    // given
    [stubber recordStubInvocation:[NSInvocation voidMethodInvocationForTarget:nil] withPrimitiveArgumentMatchers:nil];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return NO;
    }];
    
    // then
    TestObject *otherObject = [[TestObject alloc] init];
    NSInvocation *unrecordedInvocation = [NSInvocation voidMethodInvocationForTarget:otherObject];
    XCTAssertFalse([stubber hasStubsRecordedForInvocation:unrecordedInvocation], @"Should not have stubs for unrecorded invocation");
}

- (void)testThatHasStubsReturnsYesIfOneStubIsRecordedForInvocation {
    // given
    NSInvocation *recordedInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // then
    XCTAssertTrue([stubber hasStubsRecordedForInvocation:recordedInvocation], @"Should have stubs for recorded invocation");
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
    XCTAssertTrue([stubber hasStubsRecordedForInvocation:recordedInvocation], @"Should have stubs for recorded invocation");
}

- (void)testThatHasStubsReturnsYesIfManyStubsAreRecordedInManyGroupsForInvocation {
    // given
    NSInvocation *recordedInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubInvocation:recordedInvocation withPrimitiveArgumentMatchers:nil];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // then
    XCTAssertTrue([stubber hasStubsRecordedForInvocation:recordedInvocation], @"Should have stubs for recorded invocation");
}


#pragma mark - Test Adding Actions

- (void)testThatAddingActionToStubAddsAction {
    // given
    [stubber recordStubInvocation:[NSInvocation voidMethodInvocationForTarget:nil] withPrimitiveArgumentMatchers:nil];
    id<MCKStubAction> action = [MCKPerformBlockStubAction performBlockActionWithBlock:nil];
    
    // when
    [stubber addActionToLastStub:action];
    
    // then
    NSArray *actions = [[stubber.recordedStubs lastObject] actions];
    XCTAssertEqual([actions count], (NSUInteger)1, @"Wrong number of actions recorded");
    XCTAssertEqualObjects([actions lastObject], action, @"Wrong action recorded");
}

- (void)testThatApplyingStubsToInvocationAppliesStubActionToAllMatchingInvocationsInOrder {
    // given
    NSInvocation *matchingInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSMutableArray *performedActions = [NSMutableArray array];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub1"];
    }]];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub2"];
    }]];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub3"];
    }]];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // when
    [stubber applyStubsForInvocation:matchingInvocation];
    
    // then
    XCTAssertEqualObjects(performedActions, (@[ @"stub1", @"stub2", @"stub3" ]), @"Performed actions were not recorded in correct order");
}

- (void)testThatApplyingStubsToInvocationDoesNotApplyStubActionToNonMatchingInvocation {
    // given
    NSInvocation *matchingInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *nonMatchingInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSMutableArray *performedActions = [NSMutableArray array];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub1"];
    }]];
    
    [stubber recordStubInvocation:matchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub2"];
    }]];
    
    [stubber recordStubInvocation:nonMatchingInvocation withPrimitiveArgumentMatchers:nil];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"NON MATCHING INVOCATION"];
    }]];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return (candidate == prototype);
    }];
    
    // when
    [stubber applyStubsForInvocation:matchingInvocation];
    
    // then
    XCTAssertEqualObjects(performedActions, (@[ @"stub1", @"stub2" ]), @"Performed actions were not recorded in correct order");
}

@end
