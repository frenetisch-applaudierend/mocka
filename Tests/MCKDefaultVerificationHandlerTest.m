//
//  MCKDefaultVerificationHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKDefaultVerificationHandler.h"

#import "NSInvocation+TestSupport.h"
#import "TestObject.h"
#import "CannedInvocationCollection.h"


@interface MCKDefaultVerificationHandlerTest : SenTestCase
@end


@implementation MCKDefaultVerificationHandlerTest {
    MCKDefaultVerificationHandler *handler;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    handler = [[MCKDefaultVerificationHandler alloc] init];
}


#pragma mark - Test Index Matching

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                                        inRecordedInvocations:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Non-matching invocation should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsSingleIndexSetIfOneMatchIsFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                                        inRecordedInvocations:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 1, @"Should have only one result");
    STAssertTrue([indexes containsIndex:1], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfOneMatchIsFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}

- (void)testThatHandlerReturnsFirstIndexIfMultipleMatchesAreFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                                        inRecordedInvocations:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 1, @"Should have only one result");
    STAssertTrue([indexes containsIndex:2], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfMultipleMatchesAreFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    TestObject *target = [[TestObject alloc] init];
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:&reason];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected a call to -[%@ voidMethodCallWithoutParameters] but no such call was made", target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
