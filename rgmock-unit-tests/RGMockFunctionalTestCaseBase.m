//
//  RGMockFunctionalTestCaseBase.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockFunctionalTestCaseBase.h"

// Mocking Syntax
#define MOCK_SHORTHAND
#import "RGMockKeywords.h"


@implementation RGMockFunctionalTestCaseBase

#pragma mark - Setup

- (MockTestObject *)createMockTestObject {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This test class must not be executed, but overridden"
                                 userInfo:nil];
}


#pragma mark - Test Simple Mock Call and Verify

- (void)testThatVerifySucceedsForSimpleCall {
    // given
    MockTestObject *object = [self createMockTestObject];
    
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyFailsForMissingMethodCall {
    // given
    MockTestObject *object = [self createMockTestObject];
    
    // then
    AssertFails({
        verify [object voidMethodCallWithoutParameters];
    });
}

@end
