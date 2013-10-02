//
//  MCKSenTestFailureHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright 2012 coresystems ag. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKSenTestFailureHandler.h"
#import <SenTestingKit/SenTestingKit.h>


@interface FakeSenTestCase : NSObject

@property (nonatomic, readonly) NSException *lastReportedFailure;

- (void)failWithException:(NSException *)exception;

@end

@implementation FakeSenTestCase

- (void)failWithException:(NSException *)exception {
    _lastReportedFailure = exception;
}

@end


@interface MCKSenTestFailureHandlerTest : XCTestCase @end
@implementation MCKSenTestFailureHandlerTest {
    FakeSenTestCase *testCase;
    MCKSenTestFailureHandler *failureHandler;
}

#pragma mark - Setup

- (void)setUp {
    testCase = [[FakeSenTestCase alloc] init];
    failureHandler = [[MCKSenTestFailureHandler alloc] initWithTestCase:(SenTestCase *)testCase];
}


#pragma mark - Test Cases

- (void)testThatFailureHandlerReportsToTestCase {
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    XCTAssertNotNil(testCase.lastReportedFailure, @"Failure handler did not report failure");
}

- (void)testThatFailureHandlerCreatesCorrectException {
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    XCTAssertEqualObjects(testCase.lastReportedFailure.name, SenTestFailureException, @"Incorrect exception name");
}

- (void)testThatFailureHandlerSetsReason {
    // when
    [failureHandler handleFailureWithReason:@"This is my reason"];
    
    // then
    XCTAssertEqualObjects(testCase.lastReportedFailure.reason, @"This is my reason", @"Incorrect exception reason");
}

- (void)testThatFailureHandlerSetsNilReason {
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    XCTAssertTrue(testCase.lastReportedFailure.reason.length == 0, @"Incorrect exception reason when passing nil");
}

- (void)testThatFailureHandlerSetsFilenameAndLineNumber {
    // given
    [failureHandler updateFileName:@"Foofile.m" lineNumber:10];
    
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    XCTAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestFilenameKey], @"Foofile.m",
                          @"Incorrect file name reported");
    XCTAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestLineNumberKey], @10,
                          @"Incorrect line number reported");
}

@end
