//
//  MCKInvocationMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKInvocationMatcher.h"

#import "NSInvocation+TestSupport.h"
#import "TestObject.h"
#import "BlockArgumentMatcher.h"


#define stringMatcher(idx) (char[]){ (idx), 0 }

@interface MCKInvocationMatcherTest : SenTestCase
@end


@implementation MCKInvocationMatcherTest {
    MCKInvocationMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    matcher = [[MCKInvocationMatcher alloc] init];
}


#pragma mark - Test Generic Failures While Matching

- (void)testThatInvocationMatcherFailsForDifferentTargets {
    // given
    TestObject *prototypeTarget = [[TestObject alloc] init];
    TestObject *candidateTarget = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:prototypeTarget selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:candidateTarget selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different targets");
}

- (void)testThatInvocationMatcherFailsForDifferentSelectors {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(intMethodCallWithoutParameters)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different selectors");
}

- (void)testThatInvocationMatcherFailsForDifferentArgumentTypes {
    // given
    NSInvocation *prototype = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:c"]];
    NSInvocation *candidate = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:s"]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different argument types");
}


#pragma mark - Test Primitive Argument Matching

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndPrimitiveArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentPrimitiveArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 10];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test Object Argument Matching

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndObjectArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Bar"]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Bar"]];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndNilArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), nil, nil];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentObjectArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Bar"]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Foo"]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test SEL Argument Matching

- (void)testThatInvocationMatcherMatchesSameSelectorArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(self)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(self)];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentSelectorArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(self)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(class)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test C-String Argument Matching

- (void)testThatInvocationMatcherMatchesSameCStringArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"Hello" UTF8String], [@"World" UTF8String]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"Hello" UTF8String], [@"World" UTF8String]];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentCStringArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"Hello" UTF8String], [@"World" UTF8String]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"World" UTF8String], [@"Hello" UTF8String]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test Pointer Argument Matching

- (void)testThatInvocationMatcherMatchesSamePointerArguments {
    // given
    int foo, bar;
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &foo, &bar];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &foo, &bar];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentPointerArguments {
    // given
    int foo, bar;
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &foo, &bar];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:),
                               &bar, &foo];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil], @"Matcher should fail for different arguments");
}


#pragma mark - Test Argument Matcher Support

- (void)testThatInvocationMatcherUsesPassedMatchersForPrimitiveArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 1, 0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSArray *argumentMatchers = @[[[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(id value) {
        STAssertEqualObjects(value, @20, @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForObjectArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSArray *argumentMatchers = @[[[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init]];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), argumentMatchers[1], argumentMatchers[0]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), @"Foo", @"Bar"];
    
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(id value) {
        STAssertEqualObjects(value, @"Bar", @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:@[]];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForCStringArgumentsIfGiven {
    // given
    char *foo = "Foo", *bar = "Bar";
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:), stringMatcher(1), stringMatcher(0)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:), foo, bar];
    NSArray *argumentMatchers = @[[[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(NSValue *value) {
        STAssertTrue((strcmp((const char *)[value pointerValue], (const char *)bar) == 0), @"Wrong argument value passed");
        called = YES;
        return YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForSelectorArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:), stringMatcher(1), stringMatcher(0)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:), @selector(class), @selector(self)];
    NSArray *argumentMatchers = @[[[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(NSValue *value) {
        STAssertEquals((SEL)[value pointerValue], @selector(self), @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForPointerArgumentsIfGiven {
    // given
    int *foo = &(int){2}, *bar = &(int){4};
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:), (UInt8*)1, (UInt8*)0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:), foo, bar];
    NSArray *argumentMatchers = @[[[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherImplementation:^BOOL(NSValue *value) {
        STAssertEquals([value pointerValue], (void *)bar, @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

@end