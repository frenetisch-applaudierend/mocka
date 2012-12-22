//
//  MCKSenTestFailureHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKSenTestFailureHandler.h"


@interface FakeTestCase : NSObject
@property (nonatomic, readonly) NSException *lastReportedFailure;
- (void)failWithException:(NSException *)exception;
@end

@implementation FakeTestCase
- (void)failWithException:(NSException *)exception {
    _lastReportedFailure = exception;
}
@end


@interface MCKSenTestFailureHandlerTest : SenTestCase
@end

@implementation MCKSenTestFailureHandlerTest {
    FakeTestCase                *testCase;
    MCKSenTestFailureHandler *failureHandler;
}

#pragma mark - Setup

- (void)setUp {
    testCase = [[FakeTestCase alloc] init];
    failureHandler = [[MCKSenTestFailureHandler alloc] initWithTestCase:testCase];
}

#pragma mark - Test Cases

- (void)testThatFailureHandlerReportsToTestCase {
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    STAssertNotNil(testCase.lastReportedFailure, @"Failure handler did not report failure");
}

- (void)testThatFailureHandlerCreatesCorrectException {
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    STAssertEqualObjects(testCase.lastReportedFailure.name, SenTestFailureException, @"Incorrect exception name");
}

- (void)testThatFailureHandlerSetsReason {
    // when
    [failureHandler handleFailureWithReason:@"This is my reason"];
    
    // then
    STAssertEqualObjects(testCase.lastReportedFailure.reason, @"This is my reason", @"Incorrect exception reason");
}

- (void)testThatFailureHandlerSetsNilReason {
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    STAssertTrue(testCase.lastReportedFailure.reason.length == 0, @"Incorrect exception reason when passing nil");
}

- (void)testThatFailureHandlerSetsFilenameAndLineNumber {
    // given
    [failureHandler updateFileName:@"Foofile.m" lineNumber:10];
    
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    STAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestFilenameKey], @"Foofile.m", @"Incorrect file name reported");
    STAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestLineNumberKey], @10, @"Incorrect line number reported");
}

@end
