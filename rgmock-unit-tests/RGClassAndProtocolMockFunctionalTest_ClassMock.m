//
//  RGClassMockTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockTestingUtils.h"
#import "MockTestObject.h"

#import "RGMock.h"


#pragma mark - Functional Test for mocking a single Class

@interface RGClassAndProtocolMockFunctionalTest_ClassMock : SenTestCase
@end

@implementation RGClassAndProtocolMockFunctionalTest_ClassMock {
    MockTestObject *object;
}


#pragma mark - Setup

- (void)setUp {
    [super setUp];
    object = mock([MockTestObject class]);
}


#pragma mark - Test Simple Mock Call and Verify

- (void)testThatVerifySucceedsForSimpleCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyFailsForMissingMethodCall {
    // then
    AssertFails({
        verify [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifySucceedsForTwoCallsAndTwoVerifies {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyFailsIfAppliedTwiceToOneCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
    AssertFails({
        verify [object voidMethodCallWithoutParameters];
    });
}


#pragma mark - Test Stubbing

- (void)testThatStubbedReturnValueIsReturned {
    stub [object intMethodCallWithoutParameters]; whichWill returnValue(@10);
}

@end
