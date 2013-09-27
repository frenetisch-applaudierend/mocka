//
//  MCKInvocationPrototypeTest.m
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKInvocationPrototype.h"

#import "TestObject.h"
#import "NSInvocation+TestSupport.h"


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


#pragma mark - Test Prototypes without Matchers

- (void)testThatPrototypeMatchesForIdenticalTargetAndSelectorAndNoArguments {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertTrue([prototype matchesInvocation:invocation], @"Should match invocation");
}

- (void)testThatPrototypeMatchesForIdenticalTargetAndSelectorAndEqualArguments {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:argumentSelector, @1, @2];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:argumentSelector, @1, @2];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertTrue([prototype matchesInvocation:invocation], @"Should match invocation");
}

- (void)testThatPrototypeDoesNotMatchForDifferentTarget {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target2 selectorAndArguments:emptySelector];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:invocation], @"Should not match invocation");
}

- (void)testThatPrototypeDoesNotMatchForDifferentSelector {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:@selector(description)];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:emptySelector];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:invocation], @"Should not match invocation");
}

- (void)testThatPrototypeDoesNotMatchForDifferentArgument {
    // given
    NSInvocation *invocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:argumentSelector, @1, @2];
    NSInvocation *prototypeInvocation = [NSInvocation invocationForTarget:target1 selectorAndArguments:argumentSelector, @1, @1];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation];
    
    // then
    XCTAssertFalse([prototype matchesInvocation:invocation], @"Should not match invocation");
}

@end
