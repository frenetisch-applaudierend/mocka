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

#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:self.fileName forKey:MCKFileNameKey];
    [userInfo setValue:@(self.lineNumber) forKey:MCKLineNumberKey];
    @throw [NSException exceptionWithName:@"TestFailureException" reason:reason userInfo:userInfo];
}

@end
