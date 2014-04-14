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
#import "FakeInvocationPrototype.h"


@interface MCKNeverVerificationHandlerTest : XCTestCase @end
@implementation MCKNeverVerificationHandlerTest {
    MCKNeverVerificationHandler *handler;
    NSArray *invocations;
}

#pragma mark - Setup

- (void)setUp
{
    handler = [[MCKNeverVerificationHandler alloc] init];
    invocations = @[
        [NSInvocation voidMethodInvocationForTarget:nil],
        [NSInvocation voidMethodInvocationForTarget:nil],
        [NSInvocation voidMethodInvocationForTarget:nil]
    ];
}


#pragma mark - Test Zero Matches

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFound
{
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue(result.success, @"Should be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFound
{
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}


#pragma mark - Test Exactly One Match

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFound
{
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFound
{
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}


#pragma mark - Test Multiple Matches

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFound
{
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFound
{
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}


#pragma mark - Test Timeout Config

- (void)testThatHandlerDoesNeedToAwaitTimeoutForSuccess
{
    MCKVerificationResult *success = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    
    expect([handler mustAwaitTimeoutForResult:success]).to.beTruthy();
}

- (void)testThatHandlerDoesNotNeedToAwaitTimeoutForFailure
{
    MCKVerificationResult *failure = [MCKVerificationResult failureWithReason:@"" matchingIndexes:[NSIndexSet indexSet]];
    
    expect([handler mustAwaitTimeoutForResult:failure]).to.beFalsy();
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithoutParameters);
    NSInvocation *invocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector];
    FakeInvocationPrototype *prototype = [[FakeInvocationPrototype alloc] initWithInvocation:invocation];
    prototype.matcherImplementation = ^BOOL(NSInvocation *candidate) {
        return YES;
    };
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[%@ voidMethodCallWithoutParameters] but got 3", target];
    
    XCTAssertFalse(result.success, @"Should not be satisfied"); // To be sure it really failed
    XCTAssertEqualObjects(result.failureReason, expectedReason, @"Wrong error message returned");
}

@end
