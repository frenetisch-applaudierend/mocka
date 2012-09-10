//
//  RGMockInvocationMatcherTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSInvocation+TestSupport.h"
#import "MockTestObject.h"
#import "RGMockInvocationMatcher.h"
#import "DummyArgumentMatcher.h"


@interface RGMockInvocationMatcherTest : SenTestCase
@end


@implementation RGMockInvocationMatcherTest {
    RGMockInvocationMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    matcher = [[RGMockInvocationMatcher alloc] init];
}


#pragma mark - Test Generic Failures While Matching

- (void)testThatInvocationMatcherFailsForDifferentTargets {
    // given
    MockTestObject *prototypeTarget = [[MockTestObject alloc] init];
    MockTestObject *candidateTarget = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:prototypeTarget selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:candidateTarget selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different targets");
}

- (void)testThatInvocationMatcherFailsForDifferentSelectors {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(intMethodCallWithoutParameters)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different selectors");
}

- (void)testThatInvocationMatcherFailsForDifferentArgumentTypes {
    // given
    NSInvocation *prototype = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:c"]];
    NSInvocation *candidate = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:s"]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different argument types");
}


#pragma mark - Test Primitive Argument Matching

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndPrimitiveArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentPrimitiveArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 10];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test Object Argument Matching

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndObjectArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Bar"]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Bar"]];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndNilArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentObjectArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Bar"]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Foo"]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test SEL Argument Matching

- (void)testThatInvocationMatcherMatchesSameSelectorArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(self)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(self)];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentSelectorArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(self)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(class)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test C-String Argument Matching

- (void)testThatInvocationMatcherMatchesSameCStringArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"Hello" UTF8String], [@"World" UTF8String]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"Hello" UTF8String], [@"World" UTF8String]];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentCStringArguments {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"Hello" UTF8String], [@"World" UTF8String]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"World" UTF8String], [@"Hello" UTF8String]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test Pointer Argument Matching

- (void)testThatInvocationMatcherMatchesSamePointerArguments {
    // given
    int foo, bar;
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &foo, &bar];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &foo, &bar];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentPointerArguments {
    // given
    int foo, bar;
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &foo, &bar];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &bar, &foo];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test Argument Matcher Support

- (void)testThatInvocationMatcherUsesPassedMatchersForPrimitiveArgumentsIfGiven {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 1, 0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSArray *argumentMatchers = @[[[DummyArgumentMatcher alloc] init], [[DummyArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(id value) {
        STAssertEqualObjects(value, @20, @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForObjectArgumentsIfGiven {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), @1, @0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), @"Foo", @"Bar"];
    NSArray *argumentMatchers = @[[[DummyArgumentMatcher alloc] init], [[DummyArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(id value) {
        STAssertEqualObjects(value, @"Bar", @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForCStringArgumentsIfGiven {
    // given
    char *foo = "Foo", *bar = "Bar";
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:), (UInt8*)1, (UInt8*)0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:), foo, bar];
    NSArray *argumentMatchers = @[[[DummyArgumentMatcher alloc] init], [[DummyArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(NSValue *value) {
        STAssertEquals([value pointerValue], (void *)(bar), @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForSelectorArgumentsIfGiven {
    // given
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:), (UInt8*)1, (UInt8*)0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:), @selector(class), @selector(self)];
    NSArray *argumentMatchers = @[[[DummyArgumentMatcher alloc] init], [[DummyArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(NSValue *value) {
        STAssertEquals((SEL)[value pointerValue], @selector(self), @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForPointerArgumentsIfGiven {
    // given
    int *foo = &(int){2}, *bar = &(int){4};
    MockTestObject *target = [[MockTestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:), (UInt8*)1, (UInt8*)0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:), foo, bar];
    NSArray *argumentMatchers = @[[[DummyArgumentMatcher alloc] init], [[DummyArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(NSValue *value) {
        STAssertEquals([value pointerValue], (void *)bar, @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

@end
