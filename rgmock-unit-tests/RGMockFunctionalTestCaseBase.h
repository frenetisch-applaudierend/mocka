//
//  RGMockFunctionalTestCaseBase.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MockTestObject.h"

#define AssertDoesNotFail(...) @try { __VA_ARGS__ ; } @catch(id exception) { STFail(@"Failed with exception: %@", exception); }
#define AssertFails(...) @try { __VA_ARGS__ ; STFail(@"This should have failed"); } @catch(id ignored) {}


@interface RGMockFunctionalTestCaseBase : SenTestCase

- (MockTestObject *)createMockTestObject;

@end
