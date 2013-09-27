//
//  MCKXCTestFailureHandler.m
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "MCKXCTestFailureHandler.h"

#import <XCTest/XCTestCase.h>


@implementation MCKXCTestFailureHandler

#pragma mark - Initialization

- (instancetype)initWithTestCase:(XCTestCase *)testCase {
    if ((self = [super init])) {
        _testCase = testCase;
    }
    return self;
}


#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason {
    [self.testCase recordFailureWithDescription:reason inFile:self.fileName atLine:self.lineNumber expected:NO];
}

@end
