//
//  MCKExceptionFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKExceptionFailureHandler.h"


NSString * const MCKFileNameKey = @"fileName";
NSString * const MCKLineNumberKey = @"lineNumber";


@implementation MCKExceptionFailureHandler

@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;

- (void)updateCurrentFileName:(NSString *)file andLineNumber:(NSUInteger)line {
    _fileName = [file copy];
    _lineNumber = line;
}

- (void)handleFailureWithReason:(NSString *)reason {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:_fileName forKey:MCKFileNameKey];
    [userInfo setValue:@(_lineNumber) forKey:MCKLineNumberKey];
    @throw [NSException exceptionWithName:@"TestFailureException" reason:reason userInfo:userInfo];
}

@end
