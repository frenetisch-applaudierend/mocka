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
#import "MCKBlockArgumentMatcher.h"
#import "HCBlockMatcher.h"


#define stringMatcher(idx) (char[2]){ idx, '\0' }

static inline SEL selectorMatcher(UInt8 index) {
    SEL matcher = NULL;
    ((UInt8 *)(&matcher))[0] = index;
    return matcher;
}


struct mck_test_1 {
    char field1;
};

struct mck_test_2 {
    char field1;
    double field2;
};

struct mck_test_3 {
    char field1;
    double field2;
    char field3;
};

struct mck_test_4 {
    char field1;
    struct {
        char *field1;
        unsigned int field2;
        struct {
            unsigned int field1;
        } field3;
    } field2;
};


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
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different targets");
}

- (void)testThatInvocationMatcherFailsForDifferentSelectors {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithoutParameters)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(intMethodCallWithoutParameters)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different selectors");
}

- (void)testThatInvocationMatcherFailsForDifferentArgumentTypes {
    // given
    NSInvocation *prototype = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:c"]];
    NSInvocation *candidate = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:s"]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different argument types");
}


#pragma mark - Test Primitive Argument Matching

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndPrimitiveArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                 @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentPrimitiveArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 10];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different arguments");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForPrimitiveArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 1, 0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithIntParam1:intParam2:), 10, 20];
    NSArray *argumentMatchers = @[[[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherBlock:^BOOL(id value) {
        STAssertEqualObjects(value, @20, @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherFailsForDifferentDoubleArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithDoubleParam1:doubleParam2:),
                               0.0, 1.0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithDoubleParam1:doubleParam2:),
                               0.0, 1.2];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different arguments");
}


#pragma mark - Test Object Argument Matching

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndObjectArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSString *protoArg1 = @"Foo";
    NSString *protoArg2 = [NSString stringWithUTF8String:"Bar"];
    NSString *candArg1 = @"Foo";
    NSString *candArg2 = [NSString stringWithUTF8String:"Bar"];
    
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               protoArg1, protoArg2];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               candArg1, candArg2];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                 @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherMatchesSameTargetSelectorAndNilArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               nil, nil];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               nil, nil];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                 @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentObjectArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Bar"]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:),
                               @"Foo", [NSString stringWithUTF8String:"Foo"]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different arguments");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForObjectArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSArray *argumentMatchers = @[[[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init]];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), argumentMatchers[1], argumentMatchers[0]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), @"Foo", @"Bar"];
    
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherBlock:^BOOL(id value) {
        STAssertEqualObjects(value, @"Bar", @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:@[]];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

- (void)testThatInvocationMatcherUsesPassedHamcrestMatcherForObjectArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSArray *argumentMatchers = @[[[HCBlockMatcher alloc] init], [[HCBlockMatcher alloc] init]];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), argumentMatchers[1], argumentMatchers[0]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithObjectParam1:objectParam2:), @"Foo", @"Bar"];
    
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherBlock:^BOOL(id value) {
        STAssertEqualObjects(value, @"Bar", @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:@[]];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
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
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                 @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentSelectorArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(self)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               NSSelectorFromString(@"description"), @selector(class)];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different arguments");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForSelectorArgumentsIfGiven {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               selectorMatcher(1), selectorMatcher(0)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithSelectorParam1:selectorParam2:),
                               @selector(class), @selector(self)];
    NSArray *argumentMatchers = @[[[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherBlock:^BOOL(NSValue *value) {
        STAssertEquals((SEL)[value pointerValue], @selector(self), @"Wrong argument value passed");
        called = YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
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
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                 @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentCStringArguments {
    // given
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"Hello" UTF8String], [@"World" UTF8String]];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               [@"World" UTF8String], [@"Hello" UTF8String]];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different arguments");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForCStringArgumentsIfGiven {
    // given
    char *foo = "Foo", *bar = "Bar";
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:),
                               stringMatcher(1), stringMatcher(0)];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithCStringParam1:cStringParam2:), foo, bar];
    NSArray *argumentMatchers = @[[[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherBlock:^BOOL(NSString *value) {
        STAssertEqualObjects(@"Bar", value, @"Wrong value");
        called = YES;
        return YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
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
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                 @"Matcher should match identical invocations");
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
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different arguments");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForPointerArgumentsIfGiven {
    // given
    int *foo = &(int){2}, *bar = &(int){4};
    TestObject *target = [[TestObject alloc] init];
    NSInvocation *prototype = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:), (UInt8*)1, (UInt8*)0];
    NSInvocation *candidate = [NSInvocation invocationForTarget:target
                                           selectorAndArguments:@selector(voidMethodCallWithPointerParam1:pointerParam2:), foo, bar];
    NSArray *argumentMatchers = @[[[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[0] setMatcherBlock:^BOOL(NSValue *value) {
        STAssertEquals([value pointerValue], (void *)bar, @"Wrong argument value passed");
        called = YES;
        return YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}


#pragma mark - Test Struct  Argument Matching

#define StructCallMethodTypes [[NSString stringWithFormat:@"v@:%s%s", @encode(NSRange), @encode(NSRange)] UTF8String]

- (void)testThatInvocationMatcherMatchesSameStructArguments {
    // given
    NSRange foo = { 0, 0 }, bar = { 0, 0 };
    TestObject *target = [[TestObject alloc] init];
    
    NSInvocation *prototype = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:StructCallMethodTypes]];
    prototype.target = target,
    prototype.selector = @selector(voidMethodCallWithStructParam1:structParam2:);
    [prototype setArgument:&foo atIndex:2];
    [prototype setArgument:&bar atIndex:3];
    
    NSInvocation *candidate = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:StructCallMethodTypes]];
    candidate.target = target,
    candidate.selector = @selector(voidMethodCallWithStructParam1:structParam2:);
    [candidate setArgument:&foo atIndex:2];
    [candidate setArgument:&bar atIndex:3];
    
    // then
    STAssertTrue([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                 @"Matcher should match identical invocations");
}

- (void)testThatInvocationMatcherFailsForDifferentStructArguments {
    // given
    NSRange foo = { 10, 10 }, bar = { 20, 20 };
    TestObject *target = [[TestObject alloc] init];
    
    NSInvocation *prototype = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:StructCallMethodTypes]];
    prototype.target = target,
    prototype.selector = @selector(voidMethodCallWithStructParam1:structParam2:);
    [prototype setArgument:&foo atIndex:2];
    [prototype setArgument:&bar atIndex:3];
    
    NSInvocation *candidate = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:StructCallMethodTypes]];
    candidate.target = target,
    candidate.selector = @selector(voidMethodCallWithStructParam1:structParam2:);
    [candidate setArgument:&bar atIndex:2];
    [candidate setArgument:&foo atIndex:3];
    
    // then
    STAssertFalse([matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:nil],
                  @"Matcher should fail for different arguments");
}

- (void)testThatInvocationMatcherUsesPassedMatchersForStructArgumentsIfGiven {
    // given
    NSRange fooMatcher, barMatcher;
    ((UInt8 *)&fooMatcher)[0] = 0;
    ((UInt8 *)&barMatcher)[0] = 1;

    NSRange foo = NSMakeRange(0, 20);
    NSRange bar = NSMakeRange(30, 60);
    
    TestObject *target = [[TestObject alloc] init];
    
    NSInvocation *prototype = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:StructCallMethodTypes]];
    prototype.target = target,
    prototype.selector = @selector(voidMethodCallWithStructParam1:structParam2:);
    [prototype setArgument:&fooMatcher atIndex:2];
    [prototype setArgument:&barMatcher atIndex:3];
    
    NSInvocation *candidate = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:StructCallMethodTypes]];
    candidate.target = target,
    candidate.selector = @selector(voidMethodCallWithStructParam1:structParam2:);
    [candidate setArgument:&foo atIndex:2];
    [candidate setArgument:&bar atIndex:3];
    
    NSArray *argumentMatchers = @[[[MCKBlockArgumentMatcher alloc] init], [[MCKBlockArgumentMatcher alloc] init]];
    __block BOOL called = NO;
    [argumentMatchers[1] setMatcherBlock:^BOOL(NSValue *value) {
        NSRange range; [value getValue:&range];
        STAssertTrue(NSEqualRanges(range, bar), @"Wrong argument value passed");
        called = YES;
        return YES;
    }];
    
    // when
    [matcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argumentMatchers];
    
    // then
    STAssertTrue(called, @"Matcher was not called");
}

@end
