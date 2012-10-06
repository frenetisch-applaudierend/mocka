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
#import "CannedInvocationRecorder.h"
#import "RGMockExactlyVerificationHandler.h"


@interface RGMockExactlyVerificationHandlerTest : SenTestCase
@end

@implementation RGMockExactlyVerificationHandlerTest

#pragma mark - Test exactly(0)

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFoundForExactlyZero {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:0];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}


#pragma mark - Test exactly() with non-zero count

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSet]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndex:1]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = YES;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertFalse(satisfied, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsFilledIndexSetIfTwoMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 2, @"Should result in filled set");
    STAssertTrue([indexes containsIndex:1], @"First result not reported");
    STAssertTrue([indexes containsIndex:2], @"Second result not reported");
}

- (void)testThatHandlerIsSatisfiedIfTwoMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    BOOL satisfied = NO;
    [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                  inInvocationRecorder:recorder satisfied:&satisfied failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMoreThanTwoMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
    CannedInvocationRecorder *recorder = [[CannedInvocationRecorder alloc] initWithCannedResult:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    NSInvocation *prototypeInvocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    
    // when
    NSIndexSet *indexes = [handler indexesMatchingInvocation:prototypeInvocation withNonObjectArgumentMatchers:nil
                                        inInvocationRecorder:recorder satisfied:NULL failureMessage:NULL];
    
    // then
    STAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfMoreThanTwoMatchesAreFoundForExactlyTwo {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
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
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:2];
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
    [NSString stringWithFormat:@"Expected exactly 2 calls to -[%@ voidMethodCallWithoutParameters] but got 1", target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

- (void)testThatHandlerIncludesNumberOfCallsInErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    RGMockExactlyVerificationHandler *handler = [[RGMockExactlyVerificationHandler alloc] initWithCount:5];
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
    [NSString stringWithFormat:@"Expected exactly 5 calls to -[%@ voidMethodCallWithoutParameters] but got 3", target];
    STAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
