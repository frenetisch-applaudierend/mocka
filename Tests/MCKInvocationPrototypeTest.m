//
//  MCKInvocationPrototypeTest.m
//  mocka
//
//  Created by Markus Gasser on 27.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKInvocationPrototype.h"

#import "TestObject.h"
#import "MCKBlockArgumentMatcher.h"
#import "HCBlockMatcher.h"
#import "NSInvocation+TestSupport.h"
#import "MCKValueSerialization.h"


@interface MCKInvocationPrototypeTest : XCTestCase @end
@implementation MCKInvocationPrototypeTest {
    TestObject *target1;
    TestObject *target2;
    SEL emptySelector;
    SEL argumentSelector;
}

#pragma mark - Setup

- (void)setUp {
    target1 = [[TestObject alloc] init];
    target2 = [[TestObject alloc] init];
    emptySelector = @selector(voidMethodCallWithoutParameters);
    argumentSelector = @selector(voidMethodCallWithObjectParam1:objectParam2:);
}


#pragma mark - Test Prototypes without Arguments

- (void)testThatPrototypeMatchesForIdenticalTargetAndSelectorAndNoArguments {
    // given
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertTrue([prototype matchesInvocation:candidateInvocation], @"Should match invocation");
}

- (void)testThatPrototypeMatchesForIdenticalTargetAndSelectorAndEqualArguments {
    // given
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:argumentSelector, @1, @2];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:argumentSelector, @1, @2];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertTrue([prototype matchesInvocation:candidateInvocation], @"Should match invocation");
}

- (void)testThatPrototypeDoesNotMatchForDifferentTarget {
    // given
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target2 selectorAndArguments:emptySelector];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:candidateInvocation], @"Should not match invocation");
}

- (void)testThatPrototypeDoesNotMatchForDifferentSelector {
    // given
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:@selector(description)];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:candidateInvocation], @"Should not match invocation");
}


#pragma mark - Test Prototypes with Primitive Arguments

- (void)testThatPrototypeMatchesSameIntegerArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithIntParam1:intParam2:);
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 10, 20];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 10, 20];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertTrue([prototype matchesInvocation:candidateInvocation], @"Should match invocation");
}

- (void)testThatPrototypeDoesNotMatchDifferentIntegerArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithIntParam1:intParam2:);
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 10, 20];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 10, 0];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:candidateInvocation], @"Should not match invocation");
}

- (void)testThatPrototypeDoesNotMatchDifferentDoubleArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithDoubleParam1:doubleParam2:);
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 0.0, 1.0];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 0.0, 1.2];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:candidateInvocation], @"Should not match invocation");
}


#pragma mark - Test Prototypes with Object Arguments

- (void)testThatPrototypeMatchesSameTargetSelectorAndObjectArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithObjectParam1:objectParam2:);
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, @10, @20];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, @10, @20];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertTrue([prototype matchesInvocation:candidateInvocation], @"Should match invocation");
}

- (void)testThatPrototypeMatchesSameTargetSelectorAndNilArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithObjectParam1:objectParam2:);
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, nil, nil];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, nil, nil];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertTrue([prototype matchesInvocation:candidateInvocation], @"Should match invocation");
}

- (void)testThatPrototypeDoesNotMatchDifferentObjectArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithObjectParam1:objectParam2:);
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, @10, @0];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, @10, @99];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:candidateInvocation], @"Should not match invocation");
}


#pragma mark - Test Prototypes with Argument Matchers

- (void)testThatPrototypeUsesPassedMatchersIfGiven {
    // given
    // prototype invocation arguments must be 1 and 0 so the matchers are accessed correctly
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithIntParam1:intParam2:);
    NSArray *argumentMatchers = @[ [[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init] ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 10, 20];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, 1, 0];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation
                                                                          argumentMatchers:argumentMatchers];
    
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherBlock:^BOOL(id value) {
        XCTAssertEqual(mck_decodeSignedIntegerArgument(value), (SInt64)20, @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [prototype matchesInvocation:candidateInvocation];
    
    // then
    XCTAssertTrue(called, @"Matcher was not called");
}

- (void)testThatPrototypeUsesPassedHamcrestMatcherForObjectArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    SEL selector = @selector(voidMethodCallWithObjectParam1:objectParam2:);
    NSArray *argumentMatchers = @[ [[HCBlockMatcher alloc] init], [[HCBlockMatcher alloc] init] ];
    NSInvocation *candidateInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector, @10, @20];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target selectorAndArguments:selector,
                                         argumentMatchers[0], argumentMatchers[1]];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation
                                                                          argumentMatchers:nil];
    
    __block BOOL called = NO;
    [argumentMatchers[1] setMatcherBlock:^BOOL(id value) {
        XCTAssertEqualObjects(value, @20, @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [prototype matchesInvocation:candidateInvocation];
    
    // then
    XCTAssertTrue(called, @"Matcher was not called");
}

@end
