//
//  RGMockDefaultVerificationHandlerTest.m
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSInvocation+TestSupport.h"
#import "MockTestObject.h"

#import "RGMockDefaultVerificationHandler.h"


@interface RGMockDefaultVerificationHandlerTest : SenTestCase
@end


@implementation RGMockDefaultVerificationHandlerTest {
    RGMockDefaultVerificationHandler *handler;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    handler = [[RGMockDefaultVerificationHandler alloc] init];
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
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                                       inRecordedInvocations:recordedInvocations satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Non-matching invocation should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target
                                                     selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsSingleIndexSetIfOneMatchIsFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
        [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
        [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                                       inRecordedInvocations:recordedInvocations satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 1, @"Should have only one result");
    STAssertTrue([indexes containsIndex:1], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfOneMatchIsFound {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20],
    [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}

- (void)testThatHandlerReturnsFirstIndexIfMultipleMatchesAreFound {
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
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                                       inRecordedInvocations:recordedInvocations satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 1, @"Should have only one result");
    STAssertTrue([indexes containsIndex:1], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfMultipleMatchesAreFound {
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
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:@[] satisfied:&satisfied failureMessage:&reason];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected a call to -[%@ voidMethodCallWithoutParameters] but no such call was made", target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
