//
//  RGClassAndProtocolMockTest.m
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FakeMockingContext.h"
#import "RGClassAndProtocolMock.h"


@interface RGClassAndProtocolMockTest : SenTestCase
@end

@implementation RGClassAndProtocolMockTest

#pragma mark - Test Forwarding Invocations

- (void)testThatForwardInvocationCallsMockingContextsHandleInvocation {
    // given
    FakeMockingContext *fakeContext = [FakeMockingContext fakeContext];
    RGClassAndProtocolMock *mock = [[RGClassAndProtocolMock alloc] initWithContext:(id)fakeContext classAndProtocols:nil];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    
    // when
    [mock forwardInvocation:invocation];
    
    // then
    STAssertEquals([fakeContext.handledInvocations count], (NSUInteger)1, @"Wrong number of handled invocations");
    STAssertEqualObjects([fakeContext.handledInvocations objectAtIndex:0], invocation, @"Wrong invocation handled");
}

@end
