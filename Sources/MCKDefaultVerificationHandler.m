//
//  MCKDefaultVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKDefaultVerificationHandler.h"
#import "MCKInvocationMatcher.h"


@implementation MCKDefaultVerificationHandler

#pragma mark - Initializaition

+ (id)defaultHandler {
    static id defaultHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHandler = [[MCKDefaultVerificationHandler alloc] init];
    });
    return defaultHandler;
}


#pragma mark - Matching Invocations

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
            withPrimitiveArgumentMatchers:(NSArray *)matchers
                     inInvocationRecorder:(MCKInvocationRecorder *)recorder
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [recorder invocationsMatchingPrototype:prototype withPrimitiveArgumentMatchers:matchers];
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
