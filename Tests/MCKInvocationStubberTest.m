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
#import "MCKBlockArgumentMatcher.h"

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

- (void)testThatAfterFinishingRecordingNewInvocationGroupStarts {
    // when
    [stubber recordStubPrototype:prototypes[0]];
    [stubber finishRecordingStubGroup];
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
    [stubber finishRecordingStubGroup];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber finishRecordingStubGroup];
    
    [stubber recordStubPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    [stubber finishRecordingStubGroup];
    
    // then
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    XCTAssertTrue([stubber hasStubsRecordedForInvocation:invocation], @"Should have stubs for recorded invocation");
}

@end
