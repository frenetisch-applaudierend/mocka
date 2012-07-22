//
//  RGMockExactlyVerificationHandlerTest.m
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSInvocation+TestSupport.h"
#import "MockTestObject.h"

#import "RGMockExactlyVerificationHandler.h"


@interface RGMockExactlyVerificationHandlerTest : SenTestCase
@end

@implementation RGMockExactlyVerificationHandlerTest

#pragma mark - Test exactly(0)

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
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

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
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

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
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

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
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

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
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

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
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


#pragma mark - Test exactly() with non-zero count

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
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

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target
                                                     selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:&satisfied];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
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

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
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

- (void)testThatHandlerReturnsFilledIndexSetIfTwoMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:NULL];
    
    // then
    STAssertTrue([indexes count] == 2, @"Should result in empty set");
    STAssertTrue([indexes containsIndex:1], @"First result not reported");
    STAssertTrue([indexes containsIndex:2], @"Second result not reported");
}

- (void)testThatHandlerIsSatisfiedIfMoreMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:candidateInvocation inRecordedInvocations:recordedInvocations satisfied:&satisfied];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMoreMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
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

- (void)testThatHandlerIsNotSatisfiedIfMoreMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
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
