//
//  MCKFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 16.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKFailureHandler.h"
#import "MCKSenTestFailureHandler.h"
#import "MCKXCTestFailureHandler.h"
#import "MCKExceptionFailureHandler.h"


@implementation MCKFailureHandler

#pragma mark - Getting a Failure Handler

+ (instancetype)failureHandlerForTestCase:(id)testCase {
    if ([testCase isKindOfClass:NSClassFromString(@"SenTestCase")]) {
        return [[MCKSenTestFailureHandler alloc] initWithTestCase:testCase];
    } else if ([testCase isKindOfClass:NSClassFromString(@"XCTestCase")]) {
        return [[MCKXCTestFailureHandler alloc] initWithTestCase:testCase];
    } else {
        return [[MCKExceptionFailureHandler alloc] init];
    }
}


#pragma mark - Updating Location Information

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber {
    _fileName = [fileName copy];
    _lineNumber = lineNumber;
}


#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason {
}

@end
