//
//  MCKThrowExceptionStubActionTest.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKThrowExceptionStubAction.h"


@interface MCKThrowExceptionStubActionTest : XCTestCase
@end

@implementation MCKThrowExceptionStubActionTest

- (void)testThatPerformingThrowsPassedException {
    // given
    NSException *exception = [NSException exceptionWithName:@"TestException" reason:nil userInfo:nil];
    MCKThrowExceptionStubAction *action = [MCKThrowExceptionStubAction throwExceptionActionWithException:exception];
    
    // then
    XCTAssertThrowsSpecificNamed([action performWithInvocation:nil], NSException, @"TestException", @"Wrong or no exception thrown");
}

@end
