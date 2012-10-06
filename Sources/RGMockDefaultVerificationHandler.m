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
            withNonObjectArgumentMatchers:(NSArray *)matchers
                     inInvocationRecorder:(RGMockInvocationRecorder *)recorder
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [recorder invocationsMatchingPrototype:prototype withNonObjectArgumentMatchers:matchers];
    if (satisified != NULL) {
        *satisified = ([indexes count] > 0);
    }
    
    if ([indexes count] == 0 && failureMessage != NULL) {
        *failureMessage = [NSString stringWithFormat:@"Expected a call to -[%@ %@] but no such call was made",
                           prototype.target, NSStringFromSelector(prototype.selector)];
    }
    
    return (([indexes count] > 0) ? [NSIndexSet indexSetWithIndex:[indexes firstIndex]] : [NSIndexSet indexSet]);
}

@end
