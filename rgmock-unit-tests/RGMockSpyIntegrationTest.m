//
//  RGMockSpyIntegrationTestTest.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMock.h"
#import "MockTestObject.h"


@interface RGMockSpyIntegrationTest : SenTestCase
@end


@implementation RGMockSpyIntegrationTest

#pragma mark - Test Simple Verification

- (void)testThatSimpleVerifySucceeds {
    // given
    MockTestObject *testObject = [[MockTestObject alloc] init];
    MockTestObject *mockTest = mock_spy(testObject);
    
    // when
    [testObject simpleMethodCall];
    
    // then
    STAssertNoThrow([mock_verify(mock_ctx(), mockTest) simpleMethodCall], @"Verify failed");
    STAssertNoThrow([mock_verify(mock_ctx(), testObject) simpleMethodCall], @"Verify failed");
}

- (void)testThatSimpleVerifyNotifiesFailure {
    // given
    MockTestObject *testObject = [[MockTestObject alloc] init];
    MockTestObject *mockTest = mock_spy(testObject);
    
    // when
    // nothing happens
    
    // then
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), mockTest) simpleMethodCall],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
    STAssertThrowsSpecificNamed([mock_verify(mock_ctx(), testObject) simpleMethodCall],
                                NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
}

@end
