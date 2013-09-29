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


#pragma mark - Test Index Matching

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    NSIndexSet *indexes =
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:NULL failureMessage:NULL];
    
    // then
    XCTAssertTrue([indexes count] == 0, @"Non-matching invocation should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    BOOL satisfied = YES;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsSingleIndexSetIfOneMatchIsFound {
    // given
    NSUInteger indexToFind = 1;
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[indexToFind]);
    }];
    
    // when
    NSIndexSet *indexes =
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:NULL failureMessage:NULL];
    
    // then
    XCTAssertTrue([indexes count] == 1, @"Should have only one result");
    XCTAssertTrue([indexes containsIndex:indexToFind], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfOneMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    BOOL satisfied = NO;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertTrue(satisfied, @"Should be satisifed");
}

- (void)testThatHandlerReturnsFirstIndexIfMultipleMatchesAreFound {
    // given
    NSUInteger indexToFind = 2;
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[indexToFind]);
    }];
    
    // when
    NSIndexSet *indexes =
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:NULL failureMessage:NULL];
    
    // then
    XCTAssertTrue([indexes count] == 1, @"Should have only one result");
    XCTAssertTrue([indexes containsIndex:indexToFind], @"Index set did not contain the correct index");
}

- (void)testThatHandlerIsSatisfiedIfMultipleMatchesAreFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    BOOL satisfied = NO;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertTrue(satisfied, @"Should be satisifed");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithoutParameters);
    NSInvocation *invocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector];
    FakeInvocationPrototype *prototype = [[FakeInvocationPrototype alloc] initWithInvocation:invocation];
    prototype.matcherImplementation = ^BOOL(NSInvocation *candidate) {
        return NO;
    };
    
    // when
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:&reason];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected a call to -[%@ voidMethodCallWithoutParameters] but no such call was made", target];
    XCTAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
