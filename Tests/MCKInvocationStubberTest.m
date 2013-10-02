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

#import <Mocka/MCKPerformBlockStubAction.h>
#import <Mocka/MCKBlockArgumentMatcher.h>

#import "NSInvocation+TestSupport.h"
#import "FakeInvocationPrototype.h"


@interface MCKInvocationStubberTest : XCTestCase @end
@implementation MCKInvocationStubberTest {
    MCKInvocationStubber *stubber;
    NSArray *prototypes;
}

#pragma mark - Setup

- (void)setUp {
    stubber = [[MCKInvocationStubber alloc] init];
    prototypes = @[
        [self createSamplePrototype],
        [self createSamplePrototype]
    ];
}

- (MCKInvocationPrototype *)createSamplePrototype {
    NSInvocation *invocation = [NSInvocation invocationForTarget:[NSArray array]
                                            selectorAndArguments:@selector(objectAtIndex:), 0];
    NSArray *matchers = @[ [[MCKBlockArgumentMatcher alloc] init] ];
    return [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
}


#pragma mark - Test Creating Stubs

- (void)testThatRecordingStubInvocationCreatesStub {
    // when
    [stubber recordStubPrototype:prototypes[0]];
    
    // then
    XCTAssertEqual([stubber.recordedStubs count], (NSUInteger)1, @"Stub was not created");
}

- (void)testThatCreatedStubForInvocationContainsInvocationPrototype {
    // when
    [stubber recordStubPrototype:prototypes[0]];
    
    // then
    NSArray *stubbedPrototypes = [[stubber.recordedStubs lastObject] invocationPrototypes];
    XCTAssertEqualObjects([stubbedPrototypes lastObject], prototypes[0], @"Prototype was not added to stub");
}


#pragma mark - Test Group Invocation Recording

- (void)testThatRecordingMultipleStubInvocationsInRowCreatesOnlyOneStub {
    // when
    [stubber recordStubPrototype:prototypes[0]];
    [stubber recordStubPrototype:prototypes[1]];
    
    // then
    XCTAssertEqual([stubber.recordedStubs count], (NSUInteger)1, @"Only one stub should have been created");
}

- (void)testThatCreatedStubForMultipleInvocationsContainsAllInvocationPrototypes {
    // when
    [stubber recordStubPrototype:prototypes[0]];
    [stubber recordStubPrototype:prototypes[1]];
    
    // then
    NSArray *stubbedPrototypes = [[stubber.recordedStubs lastObject] invocationPrototypes];
    XCTAssertEqual([stubbedPrototypes count], (NSUInteger)2, @"Not all prototypes were added");
    XCTAssertEqualObjects(stubbedPrototypes[0], prototypes[0], @"Prototype was not added to stub");
    XCTAssertEqualObjects(stubbedPrototypes[1], prototypes[1], @"Prototype was not added to stub");
}

- (void)testThatAfterAddingActionNewInvocationGroupStarts {
    // when
    [stubber recordStubPrototype:prototypes[0]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:nil]];
    [stubber recordStubPrototype:prototypes[1]];
    
    // then
    XCTAssertEqual([stubber.recordedStubs count], (NSUInteger)2, @"Two stub should have been created");
}


#pragma mark - Test Querying for Stubs

- (void)testThatHasStubsReturnsNoIfNoStubsAreRecordedForInvocation {
    // given
    [stubber recordStubPrototype:[FakeInvocationPrototype thatNeverMatches]];
    
    // then
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    XCTAssertFalse([stubber hasStubsRecordedForInvocation:invocation], @"Should not have stubs for unrecorded invocation");
}

- (void)testThatHasStubsReturnsYesIfOneStubIsRecordedForInvocation {
    // given
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    
    // then
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    XCTAssertTrue([stubber hasStubsRecordedForInvocation:invocation], @"Should have stubs for recorded invocation");
}

- (void)testThatHasStubsReturnsYesIfManyStubsAreRecordedInOneGroupForInvocation {
    // given
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    
    // then
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    XCTAssertTrue([stubber hasStubsRecordedForInvocation:invocation], @"Should have stubs for recorded invocation");
}

- (void)testThatHasStubsReturnsYesIfManyStubsAreRecordedInManyGroupsForInvocation {
    // given
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:nil]];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:nil]];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:nil]];
    
    // then
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    XCTAssertTrue([stubber hasStubsRecordedForInvocation:invocation], @"Should have stubs for recorded invocation");
}


#pragma mark - Test Adding Actions

- (void)testThatAddingActionToStubAddsAction {
    // given
    [stubber recordStubPrototype:prototypes[0]];
    
    // when
    id<MCKStubAction> action = [MCKPerformBlockStubAction performBlockActionWithBlock:nil];
    [stubber addActionToLastStub:action];
    
    // then
    NSArray *actions = [[stubber.recordedStubs lastObject] actions];
    XCTAssertEqual([actions count], (NSUInteger)1, @"Wrong number of actions recorded");
    XCTAssertEqualObjects([actions lastObject], action, @"Wrong action recorded");
}

- (void)testThatApplyingStubsToInvocationAppliesStubActionToAllMatchingInvocationsInOrder {
    // given
    NSMutableArray *performedActions = [NSMutableArray array];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub1"];
    }]];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub2"];
    }]];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub3"];
    }]];
    
    // when
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    [stubber applyStubsForInvocation:invocation];
    
    // then
    XCTAssertEqualObjects(performedActions, (@[ @"stub1", @"stub2", @"stub3" ]), @"Performed actions are in false order");
}

- (void)testThatApplyingStubsToInvocationDoesNotApplyStubActionToNonMatchingInvocation {
    // given
    NSMutableArray *performedActions = [NSMutableArray array];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub1"];
    }]];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"stub2"];
    }]];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatNeverMatches]];
    [stubber addActionToLastStub:[MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        [performedActions addObject:@"NON MATCHING INVOCATION"];
    }]];
    
    // when
    [stubber applyStubsForInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    
    // then
    XCTAssertEqualObjects(performedActions, (@[ @"stub1", @"stub2" ]), @"Performed actions are in false order");
}

@end
