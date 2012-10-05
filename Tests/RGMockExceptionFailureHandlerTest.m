//
//  RGMockExceptionFailureHandlerTest.m
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockExceptionFailureHandler.h"


@interface RGMockExceptionFailureHandlerTest : SenTestCase
@end

@implementation RGMockExceptionFailureHandlerTest

#pragma mark - Test Cases

- (void)testThatHandleFailureThrowsException {
    RGMockExceptionFailureHandler *failureHandler = [[RGMockExceptionFailureHandler alloc] init];
    STAssertThrows([failureHandler handleFailureInFile:nil atLine:0 withReason:nil], @"This should have thrown");
}

- (void)testThatHandleFailureSetsReasonOnException {
    RGMockExceptionFailureHandler *failureHandler = [[RGMockExceptionFailureHandler alloc] init];
    @try {
        [failureHandler handleFailureInFile:nil atLine:0 withReason:@"My passed reason"];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.reason, @"My passed reason", @"Reason was not passed");
    }
}

- (void)testThatHandleFailureSetsFileOnException {
    RGMockExceptionFailureHandler *failureHandler = [[RGMockExceptionFailureHandler alloc] init];
    @try {
        [failureHandler handleFailureInFile:@"Foobar.m" atLine:0 withReason:nil];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.userInfo[RGMockFileNameKey], @"Foobar.m", @"File was not passed");
    }
}

- (void)testThatHandleFailureSetsLineOnException {
    RGMockExceptionFailureHandler *failureHandler = [[RGMockExceptionFailureHandler alloc] init];
    @try {
        [failureHandler handleFailureInFile:nil atLine:10 withReason:nil];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.userInfo[RGMockLineNumberKey], @10, @"Line was not passed");
    }
}

@end
