//
//  RGMockInvocationMatcherTest.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockInvocationMatcher.h"
#import "MockTestObject.h"
#import "NSInvocation+TestSupport.h"


@interface RGMockInvocationMatcherTest : SenTestCase {
@private
    RGMockInvocationMatcher *matcher;
}
@end


@implementation RGMockInvocationMatcherTest

#pragma mark - Test Fixtures

- (void)setUp {
    [super setUp];
    matcher = [[RGMockInvocationMatcher alloc] init];
}


#pragma mark - Test Simle Invocation Matching

- (void)testThatMatcherMatchesEqualInvocationsWithoutArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:@selector(simpleMethodCall)];
    NSInvocation *matching = [NSInvocation invocationForTarget:someTarget selectorAndArguments:@selector(simpleMethodCall)];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatchingInvocationsDoesNotMatchNonEqualInvocationsWithoutArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    MockTestObject *anotherTarget = [[MockTestObject alloc] init];
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:@selector(simpleMethodCall)];
    NSInvocation *nonMatching = [NSInvocation invocationForTarget:anotherTarget selectorAndArguments:@selector(simpleMethodCall)];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching], @"Non matching invocations did match");
}


#pragma mark - Test Matching of Object Arguments

- (void)testThatMatcherMatchesEqualInvocationWithObjectArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithObject1:object2:object3:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, @"<obj1>", @"<obj2>", @"<obj3>"];
    NSInvocation *matching   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, @"<obj1>", @"<obj2>", @"<obj3>"];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherMatchesEqualInvocationWithNilArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithObject1:object2:object3:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, nil, nil, nil];
    NSInvocation *matching   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, nil, nil, nil];

    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherDoesNotMatchInvocationWithDifferentArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithObject1:object2:object3:);
    NSInvocation *invocation   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, @"<obj1>", @"<obj2>", @"<obj3>"];
    NSInvocation *nonMatching1 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, @"<obj3>", @"<obj2>", @"<obj1>"];
    NSInvocation *nonMatching2 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,       nil, @"<obj2>", @"<obj3>"];
    NSInvocation *nonMatching3 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,       nil,       nil,       nil];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching1], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching2], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching3], @"Non matching invocations did match");
}


#pragma mark - Test Matching of Bool Arguments

- (void)testThatMatcherMatchesEqualObjectiveCBoolArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithBool1:bool2:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, NO, YES];
    NSInvocation *matching   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, NO, YES];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherDoesNotMatchDifferentObjectiveCBoolArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithBool1:bool2:);
    NSInvocation *invocation   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  NO, YES];
    NSInvocation *nonMatching1 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  NO,  NO];
    NSInvocation *nonMatching2 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, YES, YES];
    NSInvocation *nonMatching3 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, YES,  NO];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching1], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching2], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching3], @"Non matching invocations did match");
}

- (void)testThatMatcherMatchesEqualC99BoolArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithCBool1:CBool2:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, false, true];
    NSInvocation *matching   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, false, true];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherDoesNotMatchDifferentC99BoolArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithCBool1:CBool2:);
    NSInvocation *invocation   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, false,  true];
    NSInvocation *nonMatching1 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, false, false];
    NSInvocation *nonMatching2 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  true,  true];
    NSInvocation *nonMatching3 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  true, false];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching1], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching2], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching3], @"Non matching invocations did match");
}


#pragma mark - Test Matching of Int Arguments

- (void)testThatMatcherMatchesEqualIntArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithInt1:int2:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, -10, -20];
    NSInvocation *matching   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, -10, -20];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherDoesNotMatchDifferentIntArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithInt1:int2:);
    NSInvocation *invocation   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  -0, -10];
    NSInvocation *nonMatching1 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  -0,  -0];
    NSInvocation *nonMatching2 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, -10, -10];
    NSInvocation *nonMatching3 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, -10,  -0];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching1], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching2], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching3], @"Non matching invocations did match");
}

- (void)testThatMatcherMatchesEqualUintArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithUInt1:UInt2:);
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, 10, 20];
    NSInvocation *matching   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, 10, 20];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherDoesNotMatchDifferentUIntArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithUInt1:UInt2:);
    NSInvocation *invocation   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  0, 10];
    NSInvocation *nonMatching1 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,  0,  0];
    NSInvocation *nonMatching2 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, 10, 10];
    NSInvocation *nonMatching3 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, 10,  0];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching1], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching2], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching3], @"Non matching invocations did match");
}


#pragma mark - Test Matching of C String Arguments

- (void)testThatMatcherMatchesEqualCStringArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithCString1:CString2:);
    char *string1 = malloc(12 * sizeof(char)); strncpy(string1, "Hello World", 12);
    char *string2 = malloc(12 * sizeof(char)); strncpy(string2, "Hello World", 12);
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, string1, NULL];
    NSInvocation *matching   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, string2, NULL];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
    free(string1);
    free(string2);
}

- (void)testThatMatcherDoesNotMatchDifferentCStringArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    SEL selector = @selector(methodCallWithCString1:CString2:);
    char *string1 = malloc(12 * sizeof(char)); strncpy(string1, "Hello World", 12);
    char *string2 = malloc(12 * sizeof(char)); strncpy(string2, "World Hello", 12);
    
    NSInvocation *invocation   = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, string1, string2];
    NSInvocation *nonMatching1 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, string1, string1];
    NSInvocation *nonMatching2 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector, string2, string2];
    NSInvocation *nonMatching3 = [NSInvocation invocationForTarget:someTarget selectorAndArguments:selector,    NULL,    NULL];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching1], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching2], @"Non matching invocations did match");
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching3], @"Non matching invocations did match");
}

@end
