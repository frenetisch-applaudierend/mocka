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
    NSString *_fileName;
    NSUInteger _lineNumber;
}

@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;

- (id)initWithTestCase:(id)testCase {
    if ((self = [super init])) {
        _testCase = testCase;
    }
    return self;
}

- (void)updateCurrentFileName:(NSString *)file andLineNumber:(NSUInteger)line {
    _fileName = [file copy];
    _lineNumber = line;
}

- (void)handleFailureWithReason:(NSString *)reason {
    [_testCase failWithException:[NSException failureInFile:(_fileName != nil ? _fileName : @"")
                                                     atLine:(int)_lineNumber
                                            withDescription:(reason != nil ? @"%@" : nil), reason]];
}

@end
