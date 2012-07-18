//
//  RGMockReturnStubActionTest.m
//  rgmock
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockReturnStubAction.h"


@interface RGMockReturnStubActionTest : SenTestCase
@end

@implementation RGMockReturnStubActionTest

#pragma mark - Test Object Returns

- (void)testThatObjectReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = [RGMockReturnStubAction returnActionWithValue:@"Hello World"];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    id returnValue = nil; [invocation getReturnValue:&returnValue];
    STAssertEqualObjects(returnValue, @"Hello World", @"Wrong return value set");
}

- (void)testThatNilValueIsSet {
    // given
    RGMockReturnStubAction *action = [RGMockReturnStubAction returnActionWithValue:nil];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
    [invocation setReturnValue:&(NSString *){ @"Existing Return" }];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    id returnValue = @"Foo"; [invocation getReturnValue:&returnValue];
    STAssertNil(returnValue, @"Wrong return value set");
}


#pragma mark - Test Primitive Signed Integer Type Returns

- (void)testBoolReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = [RGMockReturnStubAction returnActionWithValue:@YES];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"c@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    BOOL returnValue = NO; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, YES, @"Wrong return value set");
}

- (void)testOtherIntReturns {
    STFail(@"TODO");
}


#pragma mark - Test Primitive Unsigned Integer Type Returns

- (void)testUIntReturns {
    STFail(@"TODO");
}


#pragma mark - Test Double And Float Returns

- (void)testDoubleAndFloatReturns {
    STFail(@"TODO");
}


#pragma mark - Test Struct Returns

- (void)testStructReturns {
    STFail(@"TODO");
}


#pragma mark - Test Void Returns

- (void)testThatVoidReturnIsIgnored {
    // given
    RGMockReturnStubAction *action = [RGMockReturnStubAction returnActionWithValue:@"Hello World"];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    
    // when
    [action performWithInvocation:invocation]; // if this crashes hard, then the test failed :)
}

@end
