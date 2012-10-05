//
//  RGMockThrowExceptionStubActionTest.m
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockThrowExceptionStubAction.h"


@interface RGMockThrowExceptionStubActionTest : SenTestCase
@end

@implementation RGMockThrowExceptionStubActionTest

- (void)testThatPerformingThrowsPassedException {
    // given
    NSException *exception = [NSException exceptionWithName:@"TestException" reason:nil userInfo:nil];
    RGMockThrowExceptionStubAction *action = [RGMockThrowExceptionStubAction throwExceptionActionWithException:exception];
    
    // then
    STAssertThrowsSpecificNamed([action performWithInvocation:nil], NSException, @"TestException", @"Wrong or no exception thrown");
}

@end
