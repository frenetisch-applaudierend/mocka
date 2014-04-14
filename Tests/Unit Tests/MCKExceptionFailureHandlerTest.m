//
//  MCKExceptionFailureHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright 2012 coresystems ag. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKExceptionFailureHandler.h"


@interface MCKExceptionFailureHandlerTest : XCTestCase @end
@implementation MCKExceptionFailureHandlerTest {
    MCKExceptionFailureHandler *failureHandler;
}

#pragma mark - Setup and Teardown

- (void)setUp {
    failureHandler = [[MCKExceptionFailureHandler alloc] init];
}


#pragma mark - Test Cases

- (void)testThatHandleFailureThrowsException {
    expect(^{ [failureHandler handleFailureAtLocation:nil withReason:nil]; }).to.raise(MCKTestFailureException);
}

- (void)testThatHandleFailureSetsReasonOnException {
    expect(^{
        [failureHandler handleFailureAtLocation:nil withReason:@"Error reason"];
    }).to.raiseWithReason(MCKTestFailureException, @"Error reason");
}

- (void)testThatHandleFailureSetsFileAndLineOnException {
    // given
    MCKLocation *location = [MCKLocation locationWithFileName:@"File.m" lineNumber:10];
    
    NSException *exception = nil;
    @try { [failureHandler handleFailureAtLocation:location withReason:nil]; }
    @catch (id ex) { exception = ex; }
    
    expect(exception.userInfo[MCKFileNameKey]).to.equal(@"File.m");
    expect(exception.userInfo[MCKLineNumberKey]).to.equal(@10);
}

@end
