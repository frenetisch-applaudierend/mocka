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

@implementation MCKExceptionFailureHandlerTest {
    MCKExceptionFailureHandler *failureHandler;
}

#pragma mark - Setup and Teardown

- (void)setUp {
    failureHandler = [[MCKExceptionFailureHandler alloc] init];
}


#pragma mark - Test Cases

- (void)testThatHandleFailureThrowsException {
    STAssertThrows([failureHandler handleFailureWithReason:nil], @"This should have thrown");
}

- (void)testThatHandleFailureSetsReasonOnException {
    @try {
        [failureHandler handleFailureWithReason:@"My passed reason"];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.reason, @"My passed reason", @"Reason was not passed");
    }
}

- (void)testThatHandleFailureSetsFileAndLineOnException {
    // given
    [failureHandler updateFileName:@"Foobar.m" lineNumber:10];
    
    // then
    @try {
        [failureHandler handleFailureWithReason:nil];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.userInfo[MCKFileNameKey], @"Foobar.m", @"File was not passed");
        STAssertEqualObjects(exception.userInfo[MCKLineNumberKey], @10, @"Line was not passed");
    }
}

@end
