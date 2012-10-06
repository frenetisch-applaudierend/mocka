//
//  RGMockNeverVerificationHandlerTest.m
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockNeverVerificationHandler.h"
#import "NSInvocation+TestSupport.h"
#import "MockTestObject.h"
#import "CannedInvocationRecorder.h"


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
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:2]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:2]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFound {
    // given
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:&reason];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[%@ voidMethodCallWithoutParameters] but got 1", target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

- (void)testThatHandlerIncludesNumberOfCallsInErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:&reason];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[%@ voidMethodCallWithoutParameters] but got 3", target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
