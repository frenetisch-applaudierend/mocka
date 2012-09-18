//
//  RGMockTestCase.m
//  rgmock
//
//  Created by Markus Gasser on 15.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockTestCase.h"

@implementation RGMockTestCase {
    BOOL _interceptFailures;
    NSException *_failure;
}

- (void)mock_interceptFailuresInFile:(NSString *)file line:(int)line block:(void(^)())block mode:(RGMockFailureHandlingMode)mode
                     expectedMessage:(NSString *)expectedMessage expectedFile:(NSString *)expectedFile expectedLine:(NSUInteger)expectedLine
{
    if (block == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Need a code block" userInfo:nil];
    }
    
    _interceptFailures = YES;
    @try {
        _failure = nil;
        if (block != nil) {
            block();
        }
        _interceptFailures = NO;
        
        if (mode == RGMockFailureProhibited && _failure != nil) {
            [self failWithException:[NSException failureInFile:file atLine:line withDescription:@"Unexpectedly failed with exception: %@", _failure]];
        } else if (mode == RGMockFailureRequired && _failure == nil) {
            [self failWithException:[NSException failureInFile:file atLine:line withDescription:@"This should have failed"]];
        }
        else if (_failure != nil && expectedMessage != nil && ![expectedMessage isEqualToString:_failure.reason])
        {
            [self failWithException:[NSException failureInFile:file atLine:line
                                               withDescription:@"This should have failed with: %@\nBut failed with: %@", expectedMessage, _failure.reason]];
        }
        else if (_failure != nil && expectedFile != nil && ![expectedFile isEqualToString:[_failure.userInfo objectForKey:SenTestFilenameKey]])
        {
            [self failWithException:[NSException failureInFile:file atLine:line
                                               withDescription:@"This should have failed in file: %@\nBut failed in file: %@",
                                     expectedFile, [_failure.userInfo objectForKey:SenTestFilenameKey]]];
        }
        else if (_failure != nil && expectedLine > 0 && ![@(expectedLine) isEqual:[_failure.userInfo objectForKey:SenTestLineNumberKey]])
        {
            [self failWithException:[NSException failureInFile:file atLine:line
                                               withDescription:@"This should have failed at line: %d\nBut failed at line: %@",
                                     expectedLine, [_failure.userInfo objectForKey:SenTestLineNumberKey]]];
        }
    } @finally {
        _interceptFailures = NO;
    }
}

- (void)failWithException:(NSException *)anException {
    if (_interceptFailures) {
        _failure = anException;
    } else {
        [super failWithException:anException];
    }
}

@end
