//
//  RGClassMockTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockFunctionalTestCaseBase.h"
#import "RGMockingContext.h"
#import "RGClassMock.h"


@interface RGClassMockFunctionalTest : RGMockFunctionalTestCaseBase
@end

@implementation RGClassMockFunctionalTest

- (MockTestObject *)createMockTestObject {
    return mock_classMock([MockTestObject class]);
}

@end
