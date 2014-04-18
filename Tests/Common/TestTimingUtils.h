//
//  TestTimingUtils.h
//  mocka
//
//  Created by Markus Gasser on 12/28/12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Awaiting Conditions

static inline BOOL WaitForCondition(NSTimeInterval timeout, BOOL(^condition)()) {
    NSCParameterAssert(condition != nil);
    
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    do {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        if (condition()) {
            return YES;
        }
    } while ([lastDate laterDate:[NSDate date]] == lastDate);
    return NO;
}


#pragma mark - Disabling Slow Tests

#define MCK_IS_SLOW_TEST do { if (SlowTestsAreDisabled()) { NSLog(@"*** SKIP SLOW TEST ***"); return; } } while(0);

static inline NSString* EnvOrNil(NSString *envName) {
    const char *value = getenv([envName UTF8String]);
    return (value != NULL ? [NSString stringWithUTF8String:value] : nil);
}

static inline BOOL SlowTestsAreDisabled() {
    static BOOL disabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *disableString = [[EnvOrNil(@"MCKDisableSlowTests") lowercaseString]
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        disabled = [disableString hasPrefix:@"y"];
    });
    return disabled;
}
