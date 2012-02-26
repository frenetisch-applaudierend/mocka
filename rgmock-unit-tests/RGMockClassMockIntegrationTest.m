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


@interface RGMockClassMockIntegrationTest : SenTestCase
@end


@implementation RGMockClassMockIntegrationTest

#pragma mark - Test Simple Verification

- (void)testThatSimpleVerifySucceeds {
    // given
    MockTestObject *mockTest = mock_classMock(MockTestObject.class);
    
    // when
    [mockTest simpleMethodCall];
    
    // then
    STAssertNoThrow([mock_verify(mock_ctx(), mockTest) simpleMethodCall], @"Verify failed");
}

- (void)testThatSimpleVerifyNotifiesFailure {
    // given
    MockTestObject *mockTest = mock_classMock(MockTestObject.class);
    
    // when
    // nothing happens
    
    // then
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), mockTest) simpleMethodCall],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
}


#pragma mark - Test Verification with Object Parameters

- (void)testThatVerifySucceedsIfAllObjectParametersAreEqual {
    // given
    MockTestObject *mockTest = mock_classMock(MockTestObject.class);
    id object1 = @"<object1>", object2 = @"<object2>", object3 = @"<object3>";
    
    // when
    [mockTest methodCallWithObject1:object1 object2:object2 object3:object3];
    
    // then
    STAssertNoThrow([mock_verify(mock_ctx(), mockTest) methodCallWithObject1:object1 object2:object2 object3:object3], @"Verify failed");
}

- (void)testThatVerifyFailsIfAllObjectParametersAreEqual {
    // given
    MockTestObject *mockTest = mock_classMock(MockTestObject.class);
    id object1 = @"<object1>", object2 = @"<object2>", object3 = @"<object3>";
    
    // when
    [mockTest methodCallWithObject1:object1 object2:object2 object3:object3];
    
    // then
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), mockTest) methodCallWithObject1:nil object2:object2 object3:object3],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), mockTest) methodCallWithObject1:object2 object2:object2 object3:object3],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), mockTest) methodCallWithObject1:object3 object2:object2 object3:object1],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
}


#pragma mark - Test Verification with Primitive Types

- (void)testThatVerifySucceedsIfAllPrimitiveParametersAreEqual {
    // given
    MockTestObject *mockTest = mock_classMock(MockTestObject.class);
    
    // when
    [mockTest methodCallWithBool1:YES bool2:NO];
    [mockTest methodCallWithInt1:10 int2:20];
    
    // then
    STAssertNoThrow([mock_verify(mock_ctx(), mockTest) methodCallWithBool1:YES bool2:NO], @"Verify failed");
    STAssertNoThrow([mock_verify(mock_ctx(), mockTest) methodCallWithInt1:10 int2:20], @"Verify failed");
}

- (void)testThatVerifyFailsIfNotAllPrimitiveParametersAreEqual {
    // given
    MockTestObject *mockTest = mock_classMock(MockTestObject.class);
    
    // when
    [mockTest methodCallWithBool1:YES bool2:NO];
    [mockTest methodCallWithInt1:10 int2:20];
    
    // then
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), mockTest) methodCallWithBool1:NO bool2:NO],
                                NSException, SenTestFailureException, @"Verify should have failed as a test failure");
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), mockTest)methodCallWithInt1:0 int2:0],
                                NSException, SenTestFailureException, @"Verify should have failed as a test failure");
}

@end
