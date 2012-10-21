//
//  MCKSetOutParameterStubActionTest.m
//  mocka
//
//  Created by Markus Gasser on 21.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKSetOutParameterStubAction.h"

#import "NSInvocation+TestSupport.h"


@interface MCKSetOutParameterStubActionTest : SenTestCase
- (void)outParamMethod:(id __autoreleasing *)param;
@end

@implementation MCKSetOutParameterStubActionTest

#pragma mark - Test Setting Out Objects

- (void)testThatObjectReturnValueIsSet {
    // given
    id objectValue = @"Hello";
    id paramContainer = nil;
    
    MCKSetOutParameterStubAction *action = [MCKSetOutParameterStubAction actionToSetObject:objectValue atEffectiveIndex:0];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(outParamMethod:), &paramContainer];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    STAssertTrue(paramContainer == objectValue, @"Out parameter not set correctly");
}


#pragma mark - Testing NULL parameters

- (void)testThatParameterIsNotSetIfArgumentIsNULL {
    // given
    id objectValue = @"Hello";
    
    MCKSetOutParameterStubAction *action = [MCKSetOutParameterStubAction actionToSetObject:objectValue atEffectiveIndex:0];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(outParamMethod:), NULL];
    
    // when
    [action performWithInvocation:invocation]; // will most probably crash hard if the test fails
    
    // then
    id __autoreleasing *param = NULL; [invocation getArgument:&param atIndex:2];
    STAssertTrue(param == NULL, @"Should not have been set");
}


#pragma mark - Dummy

- (void)outParamMethod:(id __autoreleasing *)param {
}

@end
