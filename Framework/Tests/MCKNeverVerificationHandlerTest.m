//
//  MCKNeverVerificationHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKNeverVerificationHandler.h"

#import "NSInvocation+TestSupport.h"
#import "TestObject.h"
#import "CannedInvocationCollection.h"


@interface MCKNeverVerificationHandlerTest : XCTestCase
@end

@implementation MCKNeverVerificationHandlerTest {
    MCKNeverVerificationHandler *handler;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    handler = [[MCKNeverVerificationHandler alloc] init];
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
    XCTAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertTrue(satisfied, @"Should be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:2]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                                        inRecordedInvocations:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    XCTAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:2]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                                        inRecordedInvocations:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    XCTAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFound {
    // given
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisifed");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    TestObject *target = [[TestObject alloc] init];
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:&reason];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[%@ voidMethodCallWithoutParameters] but got 1", target];
    XCTAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

- (void)testThatHandlerIncludesNumberOfCallsInErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    TestObject *target = [[TestObject alloc] init];
    CannedInvocationCollection *recorder = [[CannedInvocationCollection alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesMatchingInvocation:prototypeInvocation withArgumentMatchers:nil
                  inRecordedInvocations:recorder satisfied:&satisfied failureMessage:&reason];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[%@ voidMethodCallWithoutParameters] but got 3", target];
    XCTAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
