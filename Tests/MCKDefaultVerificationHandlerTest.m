//
//  MCKDefaultVerificationHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKDefaultVerificationHandler.h"

#import "NSInvocation+TestSupport.h"
#import "TestObject.h"
#import "FakeInvocationPrototype.h"


@interface MCKDefaultVerificationHandlerTest : XCTestCase
@end


@implementation MCKDefaultVerificationHandlerTest {
    MCKDefaultVerificationHandler *handler;
    NSArray *invocations;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    handler = [[MCKDefaultVerificationHandler alloc] init];
    invocations = @[
        [NSInvocation voidMethodInvocationForTarget:nil],
        [NSInvocation voidMethodInvocationForTarget:nil],
        [NSInvocation voidMethodInvocationForTarget:nil]
    ];
}


#pragma mark - Test Zero Matches

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Non-matching invocation should result in empty set");
}


#pragma mark - Test Exactly One Match

- (void)testThatHandlerIsSatisfiedIfOneMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue(result.success, @"Should be satisifed");
}

- (void)testThatHandlerReturnsSingleIndexSetIfOneMatchIsFound {
    // given
    NSUInteger indexToFind = 1;
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[indexToFind]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 1, @"Should have only one result");
    XCTAssertTrue([result.matchingIndexes containsIndex:indexToFind], @"Index set did not contain the correct index");
}


#pragma mark - Test Multiple Matches

- (void)testThatHandlerIsSatisfiedIfMultipleMatchesAreFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue(result.success, @"Should be satisifed");
}

- (void)testThatHandlerReturnsFirstIndexIfMultipleMatchesAreFound {
    // given
    NSUInteger indexToFind = 0;
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 1, @"Should have only one result");
    XCTAssertTrue([result.matchingIndexes containsIndex:indexToFind], @"Index set did not contain the correct index");
}


#pragma mark - Test Timeout Config

- (void)testThatHandlerDoesNotNeedToAwaitTimeout {
    XCTAssertFalse([handler mustAwaitTimeoutForFailure], @"Should not need to await timeout");
}

- (void)testThatHandlerDoesNotFailFast {
    XCTAssertFalse([handler failsFastDuringTimeout], @"Should not fail fast");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithoutParameters);
    NSInvocation *invocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector];
    FakeInvocationPrototype *prototype = [[FakeInvocationPrototype alloc] initWithInvocation:invocation];
    prototype.matcherImplementation = ^BOOL(NSInvocation *candidate) {
        return NO;
    };
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected a call to -[%@ voidMethodCallWithoutParameters] but no such call was made", target];
    
    XCTAssertFalse(result.success, @"Should not be satisfied"); // To be sure it really failed
    XCTAssertEqualObjects(result.failureReason, expectedReason, @"Wrong error message returned");
}

@end
