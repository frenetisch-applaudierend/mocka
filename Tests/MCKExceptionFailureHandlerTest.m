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

#pragma mark - Setup

- (void)setUp {
    failureHandler = [[MCKExceptionFailureHandler alloc] init];
}


#pragma mark - Test Updating

- (void)testThatUpdatingValuesSavesChanges {
    [failureHandler updateCurrentFileName:@"Foo.m" andLineNumber:33];
    STAssertEqualObjects(failureHandler.fileName, @"Foo.m", @"Wrong filename saved");
    STAssertEquals(failureHandler.lineNumber, (NSUInteger)33, @"Wrong line number saved");
}


#pragma mark - Test Failure Handling

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

- (void)testThatHandleFailureSetsFileOnException {
    [failureHandler updateCurrentFileName:@"Foobar.m" andLineNumber:0];
    @try {
        
        [failureHandler handleFailureWithReason:nil];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.userInfo[MCKFileNameKey], @"Foobar.m", @"File was not passed");
    }
}

- (void)testThatHandleFailureSetsLineOnException {
    [failureHandler updateCurrentFileName:nil andLineNumber:10];
    @try {
        [failureHandler handleFailureWithReason:nil];
        STFail(@"Should have thrown");
    } @catch (NSException *exception) {
        STAssertEqualObjects(exception.userInfo[MCKLineNumberKey], @10, @"Line was not passed");
    }
}

@end
