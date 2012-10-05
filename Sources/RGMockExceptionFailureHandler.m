//
//  RGMockExceptionFailureHandler.m
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockExceptionFailureHandler.h"


NSString * const RGMockFileNameKey = @"fileName";
NSString * const RGMockLineNumberKey = @"lineNumber";


@implementation RGMockExceptionFailureHandler

- (void)handleFailureInFile:(NSString *)file atLine:(NSUInteger)line withReason:(NSString *)reason {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:file forKey:RGMockFileNameKey];
    [userInfo setValue:@(line) forKey:RGMockLineNumberKey];
    @throw [NSException exceptionWithName:@"TestFailureException" reason:reason userInfo:userInfo];
}

@end
