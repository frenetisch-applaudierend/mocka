//
//  MCKSenTestFailureHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright 2012 coresystems ag. All rights reserved.
//

#define EXP_SHORTHAND
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

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

- (void)testThatFailureHandlerCreatesCorrectException {
    // when
    [failureHandler handleFailureAtLocation:nil withReason:nil];
    
    // then
    expect(testCase.lastReportedFailure.name).to.equal(SenTestFailureException);
}

- (void)testThatFailureHandlerSetsReason {
    // when
    [failureHandler handleFailureAtLocation:nil withReason:@"Error reason"];
    
    // then
    expect(testCase.lastReportedFailure.reason).to.equal(@"Error reason");
}

- (void)testThatFailureHandlerSetsNilReason {
    // when
    [failureHandler handleFailureAtLocation:nil withReason:nil];
    
    // then
    expect(testCase.lastReportedFailure.reason.length).to.equal(0);
}

- (void)testThatFailureHandlerSetsFilenameAndLineNumber {
    // given
    MCKLocation *location = [MCKLocation locationWithFileName:@"File.m" lineNumber:10];
    
    // when
    [failureHandler handleFailureAtLocation:location withReason:nil];
    
    // then
    expect(testCase.lastReportedFailure.userInfo[SenTestFilenameKey]).to.equal(@"File.m");
    expect(testCase.lastReportedFailure.userInfo[SenTestLineNumberKey]).to.equal(@10);
}

@end
