//
//  MCKXCTestFailureHandlerTest.m
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
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
    [failureHandler handleFailureWithReason:nil];
    
    // then
    XCTAssertEqual(testCase.numberOfReports, (NSUInteger)1, @"Should have exactly one report");
}

- (void)testThatFailureHandlerSetsReason {
    // when
    [failureHandler handleFailureWithReason:@"This is my reason"];
    
    // then
    XCTAssertEqualObjects(testCase.lastReportedDescription, @"This is my reason", @"Incorrect exception reason");
}

- (void)testThatFailureHandlerSetsNilReason {
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    XCTAssertTrue(testCase.lastReportedDescription.length == 0, @"Incorrect exception reason when passing nil");
}

- (void)testThatFailureHandlerSetsFilenameAndLineNumber {
    // given
    [failureHandler updateFileName:@"Foofile.m" lineNumber:10];
    
    // when
    [failureHandler handleFailureWithReason:nil];
    
    // then
    XCTAssertEqualObjects(testCase.lastReportedFileName, @"Foofile.m", @"Incorrect file name reported");
    XCTAssertEqual(testCase.lastReportedLineNumber, (NSUInteger)10, @"Incorrect line number reported");
}

@end
