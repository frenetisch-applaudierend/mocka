//
//  RGClassAndProtocolMockTest.m
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FakeMockingContext.h"
#import "MockTestObject.h"
#import "RGMockClassAndProtocolMock.h"


@interface RGMockClassAndProtocolMockTest : SenTestCase
@end

@implementation RGMockClassAndProtocolMockTest

#pragma mark - Test Initializer

- (void)testThatInitializerFailsForEmptyClassOrProtocolList {
    STAssertThrows([RGMockClassAndProtocolMock mockWithContext:nil classAndProtocols:@[]], @"Should fail for empty class and protocol list");
}

- (void)testThatInitializerFailsIfObjectIsPassedWhichIsNotClassOrProtocol {
    NSArray *invalidClassOrProtocolList = @[ [MockTestObject class], @protocol(NSCoding), @"Fail here" ];
    STAssertThrows([RGMockClassAndProtocolMock mockWithContext:nil classAndProtocols:invalidClassOrProtocolList],
                   @"Should fail for empty class and protocol list");
}


#pragma mark - Test Forwarding Invocations

- (void)testThatForwardInvocationCallsMockingContextsHandleInvocation {
    // given
    FakeMockingContext *fakeContext = [FakeMockingContext fakeContext];
    RGMockClassAndProtocolMock *mock = [RGMockClassAndProtocolMock mockWithContext:(id)fakeContext classAndProtocols:@[ [NSObject class] ]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    
    // when
    [mock forwardInvocation:invocation];
    
    // then
    STAssertEquals([fakeContext.handledInvocations count], (NSUInteger)1, @"Wrong number of handled invocations");
    STAssertEqualObjects([fakeContext.handledInvocations objectAtIndex:0], invocation, @"Wrong invocation handled");
}


#pragma mark - Test -respondsToSelector:

- (void)testThatRespondsToSelectorReturnsTrueForSelectorOnPassedClass {
    // given
    RGMockClassAndProtocolMock *mock = [RGMockClassAndProtocolMock mockWithContext:nil classAndProtocols:@[ [MockTestObject class] ]];
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(voidMethodCallWithoutParameters)], @"Mock does not respond to instance method of class");
}

- (void)testThatRespondsToSelectorReturnsTrueForSelectorOnPassedProtocol {
    // given
    RGMockClassAndProtocolMock *mock = [RGMockClassAndProtocolMock mockWithContext:nil classAndProtocols:@[ @protocol(NSCoding) ]];
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(encodeWithCoder:)], @"Mock does not respond to instance method of class");
}

- (void)testThatRespondsToSelectorReturnsTrueForSelectorsIfBothClassAndProtocolArePassed {
    // given
    RGMockClassAndProtocolMock *mock = [RGMockClassAndProtocolMock mockWithContext:nil
                                                                 classAndProtocols:@[ [MockTestObject class], @protocol(NSCoding) ]];
    
    // then
    STAssertTrue([mock respondsToSelector:@selector(voidMethodCallWithoutParameters)], @"Mock does not respond to instance method of class");
    STAssertTrue([mock respondsToSelector:@selector(encodeWithCoder:)], @"Mock does not respond to instance method of class");
}

@end
