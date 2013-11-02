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


#pragma mark - Test Applying Void Stubs

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

- (void)testThatStubAppliesVoidBlockToNonVoidInvocation {
    // given
    __block BOOL called = NO;
    stub.stubBlock = ^{ called = YES; };
    
    SEL selector = @selector(voidMethodCallWithIntParam1:intParam2:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:testObject selectorAndArguments:selector, 1, 2];
    
    // when
    [stub applyToInvocation:invocation];
    
    // then
    expect(called).to.beTruthy();
}


#pragma mark - Test Applying Stubs with Parameters

- (void)testThatStubAppliesBlockWithParamsToInvocationWithSameParams {
    // given
    __block int passedArg1 = 0;
    __block int passedArg2 = 0;
    stub.stubBlock = ^(int arg1, int arg2) {
        passedArg1 = arg1;
        passedArg2 = arg2;
    };
    
    SEL selector = @selector(voidMethodCallWithIntParam1:intParam2:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:testObject selectorAndArguments:selector, 10, 20];
    
    // when
    [stub applyToInvocation:invocation];
    
    // then
    expect(passedArg1).to.equal(10);
    expect(passedArg2).to.equal(20);
}


#pragma mark - Test Getting Return Values

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
