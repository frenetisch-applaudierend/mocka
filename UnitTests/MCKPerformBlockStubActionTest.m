//
//  MCKPerformBlockStubActionTest.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKPerformBlockStubAction.h"


@interface MCKPerformBlockStubActionTest : SenTestCase
@end

@implementation MCKPerformBlockStubActionTest

- (void)testThatPerformBlockActionPerformsGivenBlock {
    // given
    __block BOOL called = NO;
    MCKPerformBlockStubAction *action = [MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
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
    MCKPerformBlockStubAction *action = [MCKPerformBlockStubAction performBlockActionWithBlock:^(NSInvocation *inv) {
        passedInvocation = inv;
    }];
    
    // when
    NSInvocation *expectedInvocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
    [action performWithInvocation:expectedInvocation];
    
    // then
    STAssertEqualObjects(passedInvocation, expectedInvocation, @"Block was called with wrong invocation");
}

@end
