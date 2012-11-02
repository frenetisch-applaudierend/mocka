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

#pragma mark - Initialization

- (id)initWithTestCase:(id)testCase {
    if ((self = [super init])) {
        _testCase = testCase;
    }
    return self;
}


#pragma mark - Handling Failures

- (void)handleFailureInFile:(NSString *)file atLine:(NSUInteger)line withReason:(NSString *)reason {
    [_testCase failWithException:[NSException failureInFile:file atLine:(int)line withDescription:(reason != nil ? @"%@" : nil), reason]];
}

@end
