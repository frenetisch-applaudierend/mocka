//
//  RGClassMockTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockFunctionalTestCaseBase.h"
#import "RGClassMock.h"


@interface RGClassMockTest : RGMockFunctionalTestCaseBase
@end


@implementation RGClassMockTest

#pragma mark - Providing a Mock

- (MockTestObject *)createMockTestObject {
    return [RGClassMock mockForClass:[MockTestObject class]];
}

@end
