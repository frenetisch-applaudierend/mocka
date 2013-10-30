//
//  MCKSenTestFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKSenTestFailureHandler.h"


@interface NSException (SenTestSupport)

+ (id)failureInFile:(NSString *)file atLine:(int)line withDescription:(NSString *)desc, ...;
- (void)failWithException:(NSException *)ex; // actually it's on SenTestCase, but all we need is a declaration

@end


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

- (void)handleFailureWithReason:(NSString *)reason {
    NSException *ex = [NSException failureInFile:self.fileName
                                          atLine:(int)self.lineNumber
                                 withDescription:(reason != nil ? @"%@" : nil), reason];
    [_testCase failWithException:ex];
}

@end
