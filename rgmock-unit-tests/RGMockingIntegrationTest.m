//
//  RGMockingIntegrationTest.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMock.h"
#import "MockTestObject.h"


@interface RGMockingIntegrationTest : SenTestCase
@end


@implementation RGMockingIntegrationTest

#pragma mark - Test Simple Verification

- (void)testThatSimpleVerifySucceeds {
    // given
    MockTestObject *mockTest = classMock(MockTestObject.class);
    
    // when
    [mockTest simpleMethod];
    
    // then
    STAssertNoThrow([verify(mockTest) simpleMethod], @"Verify failed");
}

- (void)testThatSimpleVerifyNotifiesFailure {
    // given
    MockTestObject *mockTest = classMock(MockTestObject.class);
    
    // when
    // nothing happens
    
    // then
    STAssertThrowsSpecificNamed([verify(mockTest) simpleMethod],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
}


#pragma mark - Test Verification with Object Parameters

- (void)testThatVerifySucceedsIfAllObjectParametersAreEqual {
    // given
    MockTestObject *mockTest = classMock(MockTestObject.class);
    id object1 = @"<object1>";
    id object2 = @"<object2>";
    id object3 = @"<object3>";
    
    // when
    [mockTest methodCallWithObject1:object1 object2:object2 object3:object3];
    
    // then
    STAssertNoThrow([verify(mockTest) methodCallWithObject1:object1 object2:object2 object3:object3], @"Verify failed");
}

- (void)testThatVerifyFailsIfAllObjectParametersAreEqual {
    // given
    MockTestObject *mockTest = classMock(MockTestObject.class);
    id object1 = @"<object1>";
    id object2 = @"<object2>";
    id object3 = @"<object3>";
    
    // when
    [mockTest methodCallWithObject1:object1 object2:object2 object3:object3];
    
    // then
    STAssertThrowsSpecificNamed([verify(mockTest) methodCallWithObject1:nil object2:object2 object3:object3],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
    STAssertThrowsSpecificNamed([verify(mockTest) methodCallWithObject1:object2 object2:object2 object3:object3],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
    STAssertThrowsSpecificNamed([verify(mockTest) methodCallWithObject1:object3 object2:object2 object3:object1],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
}

@end
