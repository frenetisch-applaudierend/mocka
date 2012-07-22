//
//  RGMockNeverVerificationHandlerTest.m
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSInvocation+TestSupport.h"
#import "MockTestObject.h"

#import "RGMockNeverVerificationHandler.h"


@interface RGMockNeverVerificationHandlerTest : SenTestCase
@end

@implementation RGMockNeverVerificationHandlerTest {
    RGMockNeverVerificationHandler *handler;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    handler = [[RGMockNeverVerificationHandler alloc] init];
}


#pragma mark - Test Index Matching

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target
                                                     selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target
                                                     selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:&satisfied];
    
    // then
    STAssertTrue(satisfied, @"Should be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:&satisfied];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:&satisfied];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}

@end
