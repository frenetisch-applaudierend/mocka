//
//  RGMockInvocationStubberTest.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockInvocationStubber.h"
#import "RGMockStubbing.h"
#import "BlockInvocationMatcher.h"
#import "BlockArgumentMatcher.h"
#import "NSInvocation+TestSupport.h"


@interface RGMockInvocationStubberTest : SenTestCase
@end

@implementation RGMockInvocationStubberTest {
    RGMockInvocationStubber *stubber;
    BlockInvocationMatcher  *invocationMatcher;
}

#pragma mark - Setup

- (void)setUp {
    stubber = [[RGMockInvocationStubber alloc] init];
}


#pragma mark - Test Creating Stubbings

- (void)testThatCreatingStubbingForInvocationCreatesStubbing {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber createStubbingForInvocation:invocation nonObjectArgumentMatchers:nil];
    
    // then
    STAssertEquals([stubber.stubbings count], (NSUInteger)1, @"Stubbing was not created");
}

- (void)testThatCreatedStubbingForInvocationContainsInvocation {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [stubber createStubbingForInvocation:invocation nonObjectArgumentMatchers:nil];
    
    // then
    RGMockStubbing *stubbing = [stubber.stubbings lastObject];
    STAssertEqualObjects([[stubbing.invocationPrototypes lastObject] invocation], invocation, @"Invocation was not added to stubbing");
}

- (void)testThatCreatedStubbingForInvocationContainsArgumentMatchers {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    NSArray *argumentMatchers = @[ [[BlockArgumentMatcher alloc] init] ];
    
    // when
    [stubber createStubbingForInvocation:invocation nonObjectArgumentMatchers:argumentMatchers];
    
    // then
    RGMockStubbing *stubbing = [stubber.stubbings lastObject];
    STAssertEqualObjects([[stubbing.invocationPrototypes lastObject] nonObjectArgumentMatchers], argumentMatchers, @"Matchers were not added to stubbing");
}

@end
