//
//  MCKXCTestFailureHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 27.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKXCTestFailureHandler.h"


@interface FakeXCTestCase : NSObject

@property (nonatomic, assign) NSUInteger numberOfReports;
@property (nonatomic, copy) NSString *lastReportedDescription;
@property (nonatomic, copy) NSString *lastReportedFileName;
@property (nonatomic, assign) NSUInteger lastReportedLineNumber;
@property (nonatomic, assign) BOOL lastReportedExpectedState;

- (void)recordFailureWithDescription:(NSString *)desc inFile:(NSString *)file atLine:(NSUInteger)line expected:(BOOL)expected;

@end

@implementation FakeXCTestCase

- (void)recordFailureWithDescription:(NSString *)desc inFile:(NSString *)file atLine:(NSUInteger)line expected:(BOOL)expected {
    self.numberOfReports++;
    self.lastReportedDescription = desc;
    self.lastReportedFileName = file;
    self.lastReportedLineNumber = line;
    self.lastReportedExpectedState = expected;
}

@end


@interface MCKXCTestFailureHandlerTest : XCTestCase @end
@implementation MCKXCTestFailureHandlerTest {
    FakeXCTestCase *testCase;
    MCKXCTestFailureHandler *failureHandler;
}

#pragma mark - Setup

- (void)setUp {
    testCase = [[FakeXCTestCase alloc] init];
    failureHandler = [[MCKXCTestFailureHandler alloc] initWithTestCase:(XCTestCase *)testCase];
}


#pragma mark - Test Cases

- (void)testThatFailureHandlerReportsToTestCase {
    // when
    [failureHandler handleFailureAtLocation:nil withReason:nil];
    
    // then
    expect(testCase.numberOfReports).to.equal(1);
}

- (void)testThatFailureHandlerSetsReason {
    // when
    [failureHandler handleFailureAtLocation:nil withReason:@"Error reason"];
    
    // then
    expect(testCase.lastReportedDescription).to.equal(@"Error reason");
}

- (void)testThatFailureHandlerSetsNilReason {
    // when
    [failureHandler handleFailureAtLocation:nil withReason:nil];
    
    // then
    expect(testCase.lastReportedDescription.length).to.equal(0);
}

- (void)testThatFailureHandlerSetsFilenameAndLineNumber {
    // given
    MCKLocation *location = [MCKLocation locationWithFileName:@"File.m" lineNumber:10];
    
    // when
    [failureHandler handleFailureAtLocation:location withReason:nil];
    
    // then
    expect(testCase.lastReportedFileName).to.equal(@"File.m");
    expect(testCase.lastReportedLineNumber).to.equal(10);
}

@end
