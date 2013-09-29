//
//  MCKReturnStubActionTest.m
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKReturnStubAction.h"


#define signatureWithReturnType(retValType) _makeSignature(@encode(retValType))
static const char* _makeSignature(const char *returnType) {
    static char buffer[80];
    snprintf(buffer, 80, "%s@:", returnType);
    return buffer;
}


@interface MCKReturnStubActionTest : XCTestCase
@end

@implementation MCKReturnStubActionTest

#pragma mark - Test Object Returns

- (void)testThatObjectReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(@"Hello World");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(id)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    id returnValue = nil; [invocation getReturnValue:&returnValue];
    XCTAssertEqualObjects(returnValue, @"Hello World", @"Wrong return value set");
}

- (void)testThatClassReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction([NSString class]);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(Class)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    id returnValue = nil; [invocation getReturnValue:&returnValue];
    XCTAssertEqualObjects(returnValue, [NSString class], @"Wrong return value set");
}

- (void)testThatNilValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(nil);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(id)]];
    [invocation setReturnValue:&(NSString *){ @"Existing Return" }];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    id returnValue = @"Foo"; [invocation getReturnValue:&returnValue];
    XCTAssertNil(returnValue, @"Wrong return value set");
}


#pragma mark - Test Primitive Signed Integer Type Returns

- (void)testBoolReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(YES);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(BOOL)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    BOOL returnValue = NO; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, YES, @"Wrong return value set");
}

- (void)testCharReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(-21);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(char)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    char returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (char)-21, @"Wrong return value set");
}

- (void)testShortReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(-23003);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(short)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    short returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (short)-23003, @"Wrong return value set");
}

- (void)testIntReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(-900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(int)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    int returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (int)-900009, @"Wrong return value set");
}

- (void)testLongReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(-900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(long)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    long returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (long)-900009, @"Wrong return value set");
}

- (void)testLongLongReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(-1000000000);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(long long)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    long long returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (long long)-1000000000, @"Wrong return value set");
}


#pragma mark - Test Primitive Unsigned Integer Type Returns

- (void)testUnsignedCharReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(21);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(unsigned char)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned char returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (unsigned char)21, @"Wrong return value set");
}

- (void)testUnsignedShortReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(23003);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(unsigned short)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned short returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (unsigned short)23003, @"Wrong return value set");
}

- (void)testUnsignedIntReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(unsigned int)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned int returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (unsigned int)900009, @"Wrong return value set");
}

- (void)testUnsignedLongReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(900009);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(unsigned long)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned long returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (unsigned long)900009, @"Wrong return value set");
}

- (void)testUnsignedLongLongReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(1000000000);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(unsigned long long)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    unsigned long long returnValue = 0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (unsigned long long)1000000000, @"Wrong return value set");
}


#pragma mark - Test Double And Float Returns

- (void)testFloatReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(123.45f);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(float)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    float returnValue = 0.0f; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (float)123.45f, @"Wrong return value set");
}

- (void)testDoubleReturnValueIsSet {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(1234567.89);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(double)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    double returnValue = 0.0; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (double)1234567.89, @"Wrong return value set");
}


#pragma mark - Test Struct Returns

- (void)testNSRangeReturnValueIsSet {
    // given
    NSRange range = NSMakeRange(5, 26);
    MCKReturnStubAction *action = mck_returnStructAction(range);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(NSRange)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    NSRange returnValue = NSMakeRange(0, 0); [invocation getReturnValue:&returnValue];
    XCTAssertTrue(NSEqualRanges(returnValue, NSMakeRange(5, 26)), @"Wrong return value set");
}


#pragma mark - Test Pointer Returns

- (void)testPointerReturns {
    // given
    int foo = 0;
    MCKReturnStubAction *action = mck_returnValueAction(&foo);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(int*)]];
    
    // when
    [action performWithInvocation:invocation];
    
    // then
    int *returnValue = NULL; [invocation getReturnValue:&returnValue];
    XCTAssertEqual(returnValue, (int *)&foo, @"Wrong return value set");
}


#pragma mark - Test Void Returns

- (void)testThatVoidReturnIsIgnored {
    // given
    MCKReturnStubAction *action = mck_returnValueAction(@"Hello World");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:signatureWithReturnType(void)]];
    
    // when
    [action performWithInvocation:invocation]; // if this crashes hard, then the test failed :)
}

@end
