//
//  RGMockDefaultVerificationHandler.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockDefaultVerificationHandler.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockDefaultVerificationHandler

#pragma mark - Initializaition

+ (id)defaultHandler {
    static id defaultHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHandler = [[RGMockDefaultVerificationHandler alloc] init];
    });
    return defaultHandler;
}


#pragma mark - Matching Invocations

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(NSArray *)argumentMatchers
                    inRecordedInvocations:(NSArray *)recordedInvocations
                                satisfied:(BOOL *)satisified
{
    NSUInteger index = [recordedInvocations indexOfObjectPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
        return [[RGMockInvocationMatcher defaultMatcher] invocation:candidate matchesPrototype:prototype withArgumentMatchers:argumentMatchers];
    }];
    if (satisified != NULL) {
        *satisified = (index != NSNotFound);
    }
    return ((index != NSNotFound) ? [NSIndexSet indexSetWithIndex:index] : [NSIndexSet indexSet]);
}

@end
