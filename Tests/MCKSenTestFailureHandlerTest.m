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
    [failureHandler handleFailureInFile:nil atLine:0 withReason:nil];
    STAssertNotNil(testCase.lastReportedFailure, @"Failure handler did not report failure");
}

- (void)testThatFailureHandlerCreatesCorrectException {
    [failureHandler handleFailureInFile:nil atLine:0 withReason:nil];
    STAssertEqualObjects(testCase.lastReportedFailure.name, SenTestFailureException, @"Incorrect exception name");
}

- (void)testThatFailureHandlerSetsReason {
    [failureHandler handleFailureInFile:nil atLine:0 withReason:@"This is my reason"];
    STAssertEqualObjects(testCase.lastReportedFailure.reason, @"This is my reason", @"Incorrect exception reason");
}

- (void)testThatFailureHandlerSetsNilReason {
    [failureHandler handleFailureInFile:nil atLine:0 withReason:nil];
    STAssertTrue(testCase.lastReportedFailure.reason.length == 0, @"Incorrect exception reason when passing nil");
}

- (void)testThatFailureHandlerSetsFilename {
    [failureHandler handleFailureInFile:@"Foofile.m" atLine:0 withReason:nil];
    STAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestFilenameKey], @"Foofile.m", @"Incorrect file name reported");
}

- (void)testThatFailureHandlerSetsLineNumber {
    [failureHandler handleFailureInFile:@"Foofile.m" atLine:10 withReason:nil];
    STAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestLineNumberKey], @10, @"Incorrect line number reported");
}

@end
