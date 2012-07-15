//
//  RGMockFunctionalTestCaseBase.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MockTestObject.h"

@interface RGMockFunctionalTestCaseBase : SenTestCase

- (MockTestObject *)createMockTestObject;

@end
