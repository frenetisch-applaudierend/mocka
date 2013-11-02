//
//  MCKStubTest.m
//  mocka
//
//  Created by Markus Gasser on 2.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#define EXP_SHORTHAND
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

#import "MCKStub.h"
#import "NSInvocation+TestSupport.h"
#import "TestObject.h"


@interface MCKStubTest : XCTestCase @end
@implementation MCKStubTest {
    MCKStub *stub;
    TestObject *testObject;
}

#pragma mark - Setup

- (void)setUp {
    stub = [[MCKStub alloc] init];
    testObject = [[TestObject alloc] init];
}


#pragma mark - Test Applying Stubs

- (void)testThatStubAppliesVoidBlockToVoidInvocation {
    // given
    __block BOOL called = NO;
    stub.stubBlock = ^{ called = YES; };
    
    SEL selector = @selector(voidMethodCallWithoutParameters);
    NSInvocation *invocation = [NSInvocation invocationForTarget:testObject selectorAndArguments:selector];
    
    // when
    [stub applyToInvocation:invocation];
    
    // then
    expect(called).to.beTruthy();
}

- (void)testThatApplyToInvocationCopiesReturnValueFromBlock {
    // given
    stub.stubBlock = ^id { return @"Hello World"; };
    
    SEL selector = @selector(objectMethodCallWithoutParameters);
    NSInvocation *invocation = [NSInvocation invocationForTarget:testObject selectorAndArguments:selector];
    
    // when
    [stub applyToInvocation:invocation];
    
    // then
    id returnValue; [invocation getReturnValue:&returnValue];
    expect(returnValue).to.equal(@"Hello World");
}

@end
