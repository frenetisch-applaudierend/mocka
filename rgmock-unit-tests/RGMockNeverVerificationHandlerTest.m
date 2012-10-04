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
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                                       inRecordedInvocations:recordedInvocations satisfied:NULL failureMessage:NULL];
    
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
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:NULL];
    
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
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                                       inRecordedInvocations:recordedInvocations satisfied:NULL failureMessage:NULL];
    
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
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:NULL];
    
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
    NSIndexSet *indexes = [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                                       inRecordedInvocations:recordedInvocations satisfied:NULL failureMessage:NULL];
    
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
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[ [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)] ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:&reason];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[<%@ %p> voidMethodCallWithoutParameters] but got 1", [target class], target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

- (void)testThatHandlerIncludesNumberOfCallsInErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSArray *recordedInvocations = @[
        [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
        [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
        [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)]
    ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:candidateInvocation withNonObjectArgumentMatchers:nil
                 inRecordedInvocations:recordedInvocations satisfied:&satisfied failureMessage:&reason];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[<%@ %p> voidMethodCallWithoutParameters] but got 3", [target class], target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
