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
#import "MCKInvocationPrototype.h"
#import "MCKMockingContext.h"
#import "MCKExceptionFailureHandler.h"
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
    
    MCKMockingContext *context = [MCKMockingContext currentContext];
    context.failureHandler = [[MCKExceptionFailureHandler alloc] init];
}


#pragma mark - Test Setting Stubs

- (void)testThatSettingStubBlockSucceedsForVoidBlockAndVariousInvocations {
    // given
    NSArray *invocations = @[
        [NSInvocation invocationForTarget:testObject selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 0, 0],
        [NSInvocation invocationForTarget:testObject selectorAndArguments:@selector(voidMethodCallWithoutParameters)],
    ];
    [stub addInvocationPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocations[0]]];
    [stub addInvocationPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocations[1]]];
    
    // then
    expect(^{ stub.stubBlock = ^{ }; }).notTo.raiseAny();
}

- (void)testThatSettingStubBlockSucceedsForMatchingBlock {
    // given
    NSInvocation *inv = [NSInvocation invocationForTarget:testObject selectorAndArguments:@selector(boolMethodCallWithError:)];
    [stub addInvocationPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:inv]];
    
    // then
    expect(^{ stub.stubBlock = ^BOOL (NSError **error) { return NO; }; }).notTo.raiseAny();
}

- (void)testThatSettingStubBlockSucceedsForMatchingBlockIncludingSelfAndCmd {
    // given
    NSInvocation *inv = [NSInvocation invocationForTarget:testObject selectorAndArguments:@selector(boolMethodCallWithError:)];
    [stub addInvocationPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:inv]];
    
    // then
    expect(^{ stub.stubBlock = ^BOOL (id self, SEL _cmd, NSError **error) { return NO; }; }).notTo.raiseAny();
}

- (void)testThatSettingStubBlockSucceedsForMatchingVoidBlock {
    // given
    NSInvocation *inv = [NSInvocation invocationForTarget:testObject selectorAndArguments:@selector(boolMethodCallWithError:)];
    [stub addInvocationPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:inv]];
    
    // then
    expect(^{ stub.stubBlock = ^(NSError **error) { }; }).notTo.raiseAny();
}

- (void)testThatSettingStubBlockFailsForNonMatchingBlockArguments {
    // given
    NSInvocation *inv = [NSInvocation invocationForTarget:testObject selectorAndArguments:@selector(boolMethodCallWithError:)];
    [stub addInvocationPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:inv]];
    
    // then
    expect(^{ stub.stubBlock = ^BOOL(NSError **error, int notMatching) { return NO; }; }).to.raiseAny();
}

- (void)testThatSettingStubBlockFailsForNonMatchingBlockReturnType {
    // given
    NSInvocation *inv = [NSInvocation invocationForTarget:testObject selectorAndArguments:@selector(boolMethodCallWithError:)];
    [stub addInvocationPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:inv]];
    
    // then
    expect(^{ stub.stubBlock = ^id(NSError **error) { return nil; }; }).to.raiseAny();
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
    __block NSInteger passedArg1 = 0;
    __block NSInteger passedArg2 = 0;
    stub.stubBlock = ^(NSInteger arg1, NSInteger arg2) {
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

- (void)testThatStubAppliesBlockWithParamsToInvocationWithSameParamsForIncludedSelfAndCmd {
    // given
    __block id passedSelf = nil;
    __block SEL passedCmd = NULL;
    __block NSInteger passedArg1 = 0;
    __block NSInteger passedArg2 = 0;
    stub.stubBlock = ^(TestObject *self, SEL _cmd, NSInteger arg1, NSInteger arg2) {
        passedSelf = self;
        passedCmd = _cmd;
        passedArg1 = arg1;
        passedArg2 = arg2;
    };
    
    SEL selector = @selector(voidMethodCallWithIntParam1:intParam2:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:testObject selectorAndArguments:selector, 10, 20];
    
    // when
    [stub applyToInvocation:invocation];
    
    // then
    expect(passedSelf).to.equal(testObject);
    expect(passedCmd).to.equal(selector);
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
