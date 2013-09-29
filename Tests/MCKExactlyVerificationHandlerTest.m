//
//  MCKExactlyVerificationHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKExactlyVerificationHandler.h"

#import "NSInvocation+TestSupport.h"
#import "TestObject.h"
#import "FakeInvocationPrototype.h"


@interface MCKExactlyVerificationHandlerTest : XCTestCase
@end

@implementation MCKExactlyVerificationHandlerTest {
    NSArray *invocations;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    invocations = @[
        [NSInvocation voidMethodInvocationForTarget:nil],
        [NSInvocation voidMethodInvocationForTarget:nil],
        [NSInvocation voidMethodInvocationForTarget:nil]
    ];
}


#pragma mark - Test exactly(0)

- (void)testThatHandlerIsSatisfiedIfNoMatchIsFoundForExactlyZero {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:0];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue(result.success, @"Should be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFoundForExactlyZero {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:0];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFoundForExactlyZero {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:0];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFoundForExactlyZero {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:0];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfMultipleMatchesAreFoundForExactlyZero {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:0];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMultipleMatchesAreFoundForExactlyZero {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:0];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}


#pragma mark - Test exactly() with non-zero count

- (void)testThatHandlerIsNotSatisfiedIfNoMatchIsFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisfied");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfNoMatchIsFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatNeverMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsNotSatisfiedIfOneMatchIsFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfOneMatchIsFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}

- (void)testThatHandlerIsSatisfiedIfTwoMatchesAreFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0] || candidate == invocations[1]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue(result.success, @"Should be satisifed");
}

- (void)testThatHandlerReturnsFilledIndexSetIfTwoMatchesAreFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype withImplementation:^BOOL(NSInvocation *candidate) {
        return (candidate == invocations[0] || candidate == invocations[1]);
    }];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 2, @"Should result in filled set");
    XCTAssertTrue([result.matchingIndexes containsIndex:0], @"First result not reported");
    XCTAssertTrue([result.matchingIndexes containsIndex:1], @"Second result not reported");
}

- (void)testThatHandlerIsNotSatisfiedIfMoreThanTwoMatchesAreFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertFalse(result.success, @"Should not be satisifed");
}

- (void)testThatHandlerReturnsEmptyIndexSetIfMoreThanTwoMatchesAreFoundForExactlyTwo {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
    FakeInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    
    // when
    MCKVerificationResult *result = [handler verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertTrue([result.matchingIndexes count] == 0, @"Should result in empty set");
}


#pragma mark - Test Error Reporting

- (void)testThatHandlerReturnsErrorReasonIfNotSatisifiedForPlainMethod {
    // given
    MCKExactlyVerificationHandler *handler = [[MCKExactlyVerificationHandler alloc] initWithCount:2];
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
    [NSString stringWithFormat:@"Expected exactly 2 calls to -[%@ voidMethodCallWithoutParameters] but got 3", target];
    
    XCTAssertFalse(result.success, @"Should not be satisfied"); // To be sure it really failed
    XCTAssertEqualObjects(result.failureReason, expectedReason, @"Wrong error message returned");
}

@end
