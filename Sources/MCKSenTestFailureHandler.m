//
//  MCKSenTestFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKSenTestFailureHandler.h"
#import <SenTestingKit/SenTestingKit.h>


@implementation MCKSenTestFailureHandler {
    id _testCase;
}

@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;


#pragma mark - Initialization

- (id)initWithTestCase:(id)testCase {
    if ((self = [super init])) {
        _testCase = testCase;
    }
    return self;
}


#pragma mark - Maintaining Context File Information

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber {
    _fileName = [fileName copy];
    _lineNumber = lineNumber;
}


#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason {
    [_testCase failWithException:[NSException failureInFile:_fileName atLine:(int)_lineNumber withDescription:(reason != nil ? @"%@" : nil), reason]];
}

@end
