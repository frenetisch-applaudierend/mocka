//
//  MCKExceptionFailureHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKExceptionFailureHandler.h"


@interface MCKExceptionFailureHandlerTest : SenTestCase
@end

@implementation MCKExceptionFailureHandlerTest

#pragma mark - Test Cases

- (void)testThatHandleFailureThrowsException {
    MCKExceptionFailureHandler *failureHandler = [[MCKExceptionFailureHandler alloc] init];
    STAssertThrows([failureHandler handleFailureInFile:nil atLine:0 withReason:nil], @"This should have thrown");
}

- (void)testThatHandleFailureSetsReasonOnException {
    MCKExceptionFailureHandler *failureHandler = [[MCKExceptionFailureHandler alloc] init];
    @try {
        [failureHandler handleFailureInFile:nil atLine:0 withReason:@"My passed reason"];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.reason, @"My passed reason", @"Reason was not passed");
    }
}

- (void)testThatHandleFailureSetsFileOnException {
    MCKExceptionFailureHandler *failureHandler = [[MCKExceptionFailureHandler alloc] init];
    @try {
        [failureHandler handleFailureInFile:@"Foobar.m" atLine:0 withReason:nil];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.userInfo[MCKFileNameKey], @"Foobar.m", @"File was not passed");
    }
}

- (void)testThatHandleFailureSetsLineOnException {
    MCKExceptionFailureHandler *failureHandler = [[MCKExceptionFailureHandler alloc] init];
    @try {
        [failureHandler handleFailureInFile:nil atLine:10 withReason:nil];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.userInfo[MCKLineNumberKey], @10, @"Line was not passed");
    }
}

@end
