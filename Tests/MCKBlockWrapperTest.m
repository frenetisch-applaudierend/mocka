//
//  MCKBlockWrapperTest.m
//  mocka
//
//  Created by Markus Gasser on 2.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#define EXP_SHORTHAND
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

#import "MCKBlockWrapper.h"


@interface MCKBlockWrapperTest : XCTestCase @end
@implementation MCKBlockWrapperTest

#pragma mark - Test Initialization

- (void)testPassedBlockIsExposed {
    id block = ^{ };
    MCKBlockWrapper *wrapper = [MCKBlockWrapper wrapperForBlock:block];
    
    expect(wrapper.block).to.beIdenticalTo(block);
}


#pragma mark - Test Getting Block Information

- (void)testCanGetMethodSignatureFromWrappedBlock {
    MCKBlockWrapper *wrapper = [MCKBlockWrapper wrapperForBlock:^id (char *str, id obj, int i) { return nil; }];
    NSMethodSignature *signature = wrapper.blockSignature;
    
    expect(signature.methodReturnType[0]).to.equal(@encode(id)[0]);               // return type is id
    expect([signature getArgumentTypeAtIndex:0][0]).to.equal(@encode(id)[0]);     // arg 0 is the block itself
    expect([signature getArgumentTypeAtIndex:1][0]).to.equal(@encode(char*)[0]);  // arg 1 is (char *str)
    expect([signature getArgumentTypeAtIndex:2][0]).to.equal(@encode(id)[0]);     // arg 2 is (id obj)
    expect([signature getArgumentTypeAtIndex:3][0]).to.equal(@encode(int)[0]);    // arg 3 is (int i)
}


#pragma mark - Test Executing the Block

- (void)testCanInvokeBlockWithoutParameters {
    // given
    __block BOOL called = NO;
    id block = ^{ called = YES; };
    MCKBlockWrapper *wrapper = [MCKBlockWrapper wrapperForBlock:block];
    
    // when
    [wrapper invoke];
    
    // then
    expect(called).to.beTruthy();
}

- (void)testCanInvokeBlockWithDefaultParameters {
    // given
    __block NSUInteger passedArg = 0xABCD;
    id block = ^(NSUInteger arg) { passedArg = arg; };
    MCKBlockWrapper *wrapper = [MCKBlockWrapper wrapperForBlock:block];
    
    // when
    [wrapper invoke];
    
    // then
    expect(passedArg).to.equal(0);
}

- (void)testCanInvokeBlockWithCustomParameters {
    // given
    __block NSUInteger passedArg = 0xABCD;
    id block = ^(NSUInteger arg) { passedArg = arg; };
    MCKBlockWrapper *wrapper = [MCKBlockWrapper wrapperForBlock:block];
    
    // when
    [wrapper setParameter:&(NSUInteger){ 42 } atIndex:0];
    [wrapper invoke];
    
    // then
    expect(passedArg).to.equal(42);
}

- (void)testCanInvokeBlockWithPassByReferenceParameters {
    // given
    NSUInteger passedArg = 0xABCD;
    NSUInteger *argRef = &passedArg;
    id block = ^(NSUInteger *arg) { *arg = 42; };
    MCKBlockWrapper *wrapper = [MCKBlockWrapper wrapperForBlock:block];
    
    // when
    [wrapper setParameter:&argRef atIndex:0];
    [wrapper invoke];
    
    // then
    expect(passedArg).to.equal(42);
}

- (void)testCanGetReturnValueFromBlockInvocation {
    // given
    id block = ^id(void) { return @"Hello World"; };
    MCKBlockWrapper *wrapper = [MCKBlockWrapper wrapperForBlock:block];
    
    // when
    [wrapper invoke];
    
    id returnValue;
    [wrapper getReturnValue:&returnValue];
    
    // then
    expect(returnValue).to.equal(@"Hello World");
}

@end
