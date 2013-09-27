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


@interface MCKNeverVerificationHandlerTest : XCTestCase
@end

@implementation MCKNeverVerificationHandlerTest {
    MCKNeverVerificationHandler *handler;
    NSArray *invocations;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    handler = [[MCKNeverVerificationHandler alloc] init];
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
    XCTAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    BOOL satisfied = NO;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertTrue(satisfied, @"Should be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    NSIndexSet *indexes =
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:NULL failureMessage:NULL];
    
    // then
    XCTAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    BOOL satisfied = YES;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    NSIndexSet *indexes =
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:NULL failureMessage:NULL];
    
    // then
    XCTAssertTrue([indexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFound {
    // given
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    BOOL satisfied = YES;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:NULL];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisifed");
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
    BOOL satisfied = YES;
    NSString *reason = nil;
    [handler indexesOfInvocations:invocations matchingForPrototype:prototype satisfied:&satisfied failureMessage:&reason];
    
    // then
    XCTAssertFalse(satisfied, @"Should not be satisfied"); // To be sure it really failed
    
    NSString *expectedReason =
    [NSString stringWithFormat:@"Expected no calls to -[%@ voidMethodCallWithoutParameters] but got 3", target];
    XCTAssertEqualObjects(reason, expectedReason, @"Wrong error message returned");
}

@end
