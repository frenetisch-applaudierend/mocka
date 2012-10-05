//
//  RGMockSenTestFailureHandler.m
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockSenTestFailureHandler.h"
#import <SenTestingKit/SenTestingKit.h>


@implementation RGMockSenTestFailureHandler {
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
    [_testCase failWithException:[NSException failureInFile:file atLine:line withDescription:(reason != nil ? @"%@" : nil), reason]];
}

@end
