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


#pragma mark - Test Updating

- (void)testThatUpdatingValuesSavesChanges {
    [failureHandler updateCurrentFileName:@"Foo.m" andLineNumber:33];
    STAssertEqualObjects(failureHandler.fileName, @"Foo.m", @"Wrong filename saved");
    STAssertEquals(failureHandler.lineNumber, (NSUInteger)33, @"Wrong line number saved");
}


#pragma mark - Test Failure Reporting

- (void)testThatFailureHandlerReportsToTestCase {
    [failureHandler handleFailureWithReason:nil];
    STAssertNotNil(testCase.lastReportedFailure, @"Failure handler did not report failure");
}

- (void)testThatFailureHandlerCreatesCorrectException {
    [failureHandler handleFailureWithReason:nil];
    STAssertEqualObjects(testCase.lastReportedFailure.name, SenTestFailureException, @"Incorrect exception name");
}

- (void)testThatFailureHandlerSetsReason {
    [failureHandler handleFailureWithReason:@"This is my reason"];
    STAssertEqualObjects(testCase.lastReportedFailure.reason, @"This is my reason", @"Incorrect exception reason");
}

- (void)testThatFailureHandlerSetsNilReason {
    [failureHandler handleFailureWithReason:nil];
    STAssertTrue(testCase.lastReportedFailure.reason.length == 0, @"Incorrect exception reason when passing nil");
}

- (void)testThatFailureHandlerSetsFilename {
    [failureHandler updateCurrentFileName:@"Foofile.m" andLineNumber:0];
    [failureHandler handleFailureWithReason:nil];
    STAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestFilenameKey], @"Foofile.m", @"Incorrect file name reported");
}

- (void)testThatFailureHandlerSetsLineNumber {
    [failureHandler updateCurrentFileName:nil andLineNumber:10];
    [failureHandler handleFailureWithReason:nil];
    STAssertEqualObjects(testCase.lastReportedFailure.userInfo[SenTestLineNumberKey], @10, @"Incorrect line number reported");
}

@end
