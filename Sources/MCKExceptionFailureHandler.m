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

- (void)handleFailureInFile:(NSString *)file atLine:(NSUInteger)line withReason:(NSString *)reason {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:file forKey:MCKFileNameKey];
    [userInfo setValue:@(line) forKey:MCKLineNumberKey];
    @throw [NSException exceptionWithName:@"TestFailureException" reason:reason userInfo:userInfo];
}

@end
