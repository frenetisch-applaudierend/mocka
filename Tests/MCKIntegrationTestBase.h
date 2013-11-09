//
//  MCKIntegrationTestBase.h
//  mocka
//
//  Created by Markus Gasser on 2.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#define EXP_SHORTHAND
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

#import "Mocka.h"

#import "TestObject.h"
#import "TestExceptionUtils.h"
#import "CategoriesTestClasses.h"


@interface MCKIntegrationTestBase : XCTestCase

@property (nonatomic, readonly) TestObject *testObject;

- (TestObject *)createTestObject;
- (CategoriesTestMockedClass *)createCategoriesTestObject;

@end
