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
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethod)];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethod);
    invocation.target = someTarget;
    
    NSInvocation *matching = [NSInvocation invocationWithMethodSignature:signature];
    matching.selector = @selector(simpleMethod);
    matching.target = someTarget;
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatchingInvocationsDoesNotMatchNonEqualInvocationsWithoutArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    MockTestObject *anotherTarget = [[MockTestObject alloc] init];
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(simpleMethod)];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(simpleMethod);
    invocation.target = someTarget;
    
    NSInvocation *nonMatching = [NSInvocation invocationWithMethodSignature:signature];
    nonMatching.selector = @selector(simpleMethod);
    nonMatching.target = anotherTarget;
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching], @"Non matching invocations did match");
}


#pragma mark - Test Matching of Object Arguments

- (void)testThatMatcherMatchesEqualInvocationWithObjectArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    id object1 = @"<object1>"; id object2 = @"<object2>"; id object3 = @"<object3>";
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(methodCallWithObject1:object2:object3:)];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(methodCallWithObject1:object2:object3:);
    invocation.target = someTarget;
    [invocation setArgument:&object1 atIndex:2]; [invocation setArgument:&object2 atIndex:3]; [invocation setArgument:&object3 atIndex:4];
    
    NSInvocation *matching = [NSInvocation invocationWithMethodSignature:signature];
    matching.selector = @selector(methodCallWithObject1:object2:object3:);
    matching.target = someTarget;
    [matching setArgument:&object1 atIndex:2]; [matching setArgument:&object2 atIndex:3]; [matching setArgument:&object3 atIndex:4];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherMatchesEqualInvocationWithNilArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    id object1 = nil; id object2 = nil; id object3 = nil;
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(methodCallWithObject1:object2:object3:)];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(methodCallWithObject1:object2:object3:);
    invocation.target = someTarget;
    [invocation setArgument:&object1 atIndex:2]; [invocation setArgument:&object2 atIndex:3]; [invocation setArgument:&object3 atIndex:4];
    
    NSInvocation *matching = [NSInvocation invocationWithMethodSignature:signature];
    matching.selector = @selector(methodCallWithObject1:object2:object3:);
    matching.target = someTarget;
    [matching setArgument:&object1 atIndex:2]; [matching setArgument:&object2 atIndex:3]; [matching setArgument:&object3 atIndex:4];
    
    // then
    STAssertTrue([matcher invocation:invocation matchesInvocation:matching], @"Matching invocations didn't match");
}

- (void)testThatMatcherDoesNotMatchInvocationWithDifferentArguments {
    // given
    MockTestObject *someTarget = [[MockTestObject alloc] init];
    id object1 = @"<object1>"; id object2 = @"<object2>"; id object3 = @"<object3>";
    NSMethodSignature *signature = [MockTestObject instanceMethodSignatureForSelector:@selector(methodCallWithObject1:object2:object3:)];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = @selector(methodCallWithObject1:object2:object3:);
    invocation.target = someTarget;
    [invocation setArgument:&object1 atIndex:2]; [invocation setArgument:&object2 atIndex:3]; [invocation setArgument:&object3 atIndex:4];
    
    NSInvocation *nonMatching = [NSInvocation invocationWithMethodSignature:signature];
    nonMatching.selector = @selector(methodCallWithObject1:object2:object3:);
    nonMatching.target = someTarget;
    [nonMatching setArgument:&object3 atIndex:2]; [nonMatching setArgument:&object2 atIndex:3]; [nonMatching setArgument:&object1 atIndex:4];
    
    // then
    STAssertFalse([matcher invocation:invocation matchesInvocation:nonMatching], @"Non matching invocations did match");
}

@end
