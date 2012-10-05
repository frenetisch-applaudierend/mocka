//
//  RGMockPerformBlockStubActionTest.m
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockPerformBlockStubAction.h"


@interface RGMockPerformBlockStubActionTest : SenTestCase
@end

@implementation RGMockPerformBlockStubActionTest

- (void)testThatPerformBlockActionPerformsGivenBlock {
    // given
    __block BOOL called = NO;
    RGMockPerformBlockStubAction *action = [RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        called = YES;
    }];
    
    // when
    [action performWithInvocation:[NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]]];
    
    // then
    STAssertTrue(called, @"Block was not called");
}

- (void)testThatPerformBlockActionPassesInvocationToBlock {
    // given
    __block NSInvocation *passedInvocation = nil;
    RGMockPerformBlockStubAction *action = [RGMockPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        passedInvocation = inv;
    }];
    
    // when
    NSInvocation *expectedInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
    [action performWithInvocation:expectedInvocation];
    
    // then
    STAssertEqualObjects(passedInvocation, expectedInvocation, @"Block was called with wrong invocation");
}

@end
