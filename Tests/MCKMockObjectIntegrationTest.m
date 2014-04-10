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

@end
