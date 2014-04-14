//
//  ExampleTestCase.m
//  Examples
//
//  Created by Markus Gasser on 07.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"


@interface ExampleTestCase ()
@property (nonatomic, assign) BOOL mck_failsWithException;
@end

@implementation ExampleTestCase

- (void)mck_executeWithExceptionFailures:(void(^)(void))block
{
    NSParameterAssert(block != nil);
    
    self.mck_failsWithException = YES;
    block();
    self.mck_failsWithException = NO;
}

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename
                              atLine:(NSUInteger)lineNumber expected:(BOOL)expected
{
    if (self.mck_failsWithException) {
        @throw [NSException exceptionWithName:@"TestFailureException" reason:description userInfo:nil];
    }
    else {
        [super recordFailureWithDescription:description inFile:filename atLine:lineNumber expected:expected];
    }
}

@end


BOOL WaitForCondition(NSTimeInterval timeout, BOOL(^condition)(void)) {
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
