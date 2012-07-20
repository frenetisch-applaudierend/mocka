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
    RGMockReturnStubAction *action = mock_returnValueAction(@"Hello World");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    id returnValue = nil; [invocation getReturnValue:&returnValue];
    STAssertEqualObjects(returnValue, @"Hello World", @"Wrong return value set");
}

- (void)testThatNilValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(nil);
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
    RGMockReturnStubAction *action = mock_returnValueAction(YES);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"c@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    BOOL returnValue = NO; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, YES, @"Wrong return value set");
}

- (void)testCharReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(-21);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"c@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    char returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (char)-21, @"Wrong return value set");
}

- (void)testShortReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(-23003);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"s@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    short returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (short)-23003, @"Wrong return value set");
}

- (void)testIntReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(-900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"i@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    int returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (int)-900009, @"Wrong return value set");
}

- (void)testLongReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(-900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"l@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    long returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (long)-900009, @"Wrong return value set");
}

- (void)testLongLongReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(-1000000000);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"q@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    long long returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (long long)-1000000000, @"Wrong return value set");
}


#pragma mark - Test Primitive Unsigned Integer Type Returns

- (void)testUnsignedCharReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(21);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"C@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned char returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (unsigned char)21, @"Wrong return value set");
}

- (void)testUnsignedShortReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(23003);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"S@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned short returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (unsigned short)23003, @"Wrong return value set");
}

- (void)testUnsignedIntReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"I@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned int returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (unsigned int)900009, @"Wrong return value set");
}

- (void)testUnsignedLongReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"L@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned long returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (unsigned long)900009, @"Wrong return value set");
}

- (void)testUnsignedLongLongReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(1000000000);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"Q@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned long long returnValue = 0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (unsigned long long)1000000000, @"Wrong return value set");
}


#pragma mark - Test Double And Float Returns

- (void)testFloatReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(123.45f);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"f@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    float returnValue = 0.0f; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (float)123.45f, @"Wrong return value set");
}

- (void)testDoubleReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(1234567.89);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"d@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    double returnValue = 0.0; [invocation getReturnValue:&returnValue];
    STAssertEquals(returnValue, (double)1234567.89, @"Wrong return value set");
}


#pragma mark - Test Struct Returns

- (void)testNSRangeReturnValueIsSet {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(NSMakeRange(5, 26));
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"{_NSRange=II}@:"]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    NSRange returnValue = NSMakeRange(0, 0); [invocation getReturnValue:&returnValue];
    STAssertTrue(NSEqualRanges(returnValue, NSMakeRange(5, 26)), @"Wrong return value set");
}


#pragma mark - Test Pointer Returns

- (void)testPointerReturns {
    STFail(@"TODO");
}


#pragma mark - Test Void Returns

- (void)testThatVoidReturnIsIgnored {
    // given
    RGMockReturnStubAction *action = mock_returnValueAction(@"Hello World");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    
    // when
    [action performWithInvocation:invocation]; // if this crashes hard, then the test failed :)
}

@end
