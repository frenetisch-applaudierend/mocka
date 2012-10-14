//
//  RGMockDefaultVerificationHandlerTest.m
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockDefaultVerificationHandler.h"
#import "NSInvocation+TestSupport.h"
#import "MockTestObject.h"
#import "CannedInvocationRecorder.h"


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
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withPrimitiveArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Non-matching invocation should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withPrimitiveArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsSingleIndexSetIfOneMatchIsFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withPrimitiveArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 1, @"Should have only one result");
    STAssertTrue([indexes containsIndex:1], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfOneMatchIsFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withPrimitiveArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}

- (void)testThatHandlerReturnsFirstIndexIfMultipleMatchesAreFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withPrimitiveArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 1, @"Should have only one result");
    STAssertTrue([indexes containsIndex:2], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfMultipleMatchesAreFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withPrimitiveArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:prototypeInvocation withPrimitiveArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:&reason];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected a call to -[%@ voidMethodCallWithoutParameters] but no such call was made", target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
