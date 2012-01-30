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

#pragma mark - Testing Verify

- (void)testThatSimpleVerifySucceeds {
    // given
    MockTestObject *mockTest = mock(MockTestObject.class);
    
    // when
    [mockTest simpleMethod];
    
    // then
    [verify(mockTest) simpleMethod];
}

- (void)testThatSimpleVerifyNotifiesFailure {
    // given
    MockTestObject *mockTest = mock(MockTestObject.class);
    
    // when
    // nothing happens
    
    // then
    STAssertThrowsSpecificNamed([verify(mockTest) simpleMethod], NSException, SenTestFailureException,
                                @"Verify should have failed as a test failure");
}

@end
