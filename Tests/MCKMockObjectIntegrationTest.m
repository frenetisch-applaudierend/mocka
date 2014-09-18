//
//  RGClassMockTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKIntegrationTestBase.h"


#pragma mark - Functional Test for mocking a single Class

@interface MCKMockObjectIntegrationTest : MCKIntegrationTestBase
@end

@implementation MCKMockObjectIntegrationTest

#pragma mark - Setup

- (TestObject *)createTestObjectMock {
    return mockForClass(TestObject);
}

- (CategoriesTestMockedClass *)createCategoriesTestObject {
    return mockForClass(CategoriesTestMockedClass);
}


#pragma mark - Test Other Properties

- (void)testMocksArePersistent
{
    __weak TestObject *weakMock = mockForClass(TestObject);
    
    expect(weakMock).notTo.beNil();
}

- (void)testSpiesCanSafelyBeCalledAfterContextIsGone
{
    TestObject *testMock = mockForClass(TestObject);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [testMock voidMethodCallWithoutParameters];
    });
    
    // if this crashes then we can't safely call the spy
}

@end
