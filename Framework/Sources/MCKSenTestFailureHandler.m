//
//  MCKSenTestFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKSenTestFailureHandler.h"

#import <SenTestingKit/NSException_SenTestFailure.h>
#import <SenTestingKit/SenTestCase.h>


@implementation MCKSenTestFailureHandler {
    id _testCase;
}

#pragma mark - Initialization

- (id)initWithTestCase:(SenTestCase *)testCase {
    if ((self = [super init])) {
        _testCase = testCase;
    }
    return self;
}


#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason {
    NSException *ex = [NSException failureInFile:self.fileName atLine:(int)self.lineNumber withDescription:(reason != nil ? @"%@" : nil), reason];
    [_testCase failWithException:ex];
}

@end
