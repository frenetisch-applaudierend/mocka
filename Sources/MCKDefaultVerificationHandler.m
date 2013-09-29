//
//  MCKDefaultVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKDefaultVerificationHandler.h"

#import "MCKInvocationPrototype.h"


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

- (NSIndexSet *)indexesOfInvocations:(NSArray *)invocations
                matchingForPrototype:(MCKInvocationPrototype *)prototype
                           satisfied:(BOOL *)satisified
                      failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [invocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *invocation, NSUInteger idx, BOOL *stop) {
        return [prototype matchesInvocation:invocation];
    }];
    
    if (satisified != NULL) {
        *satisified = ([indexes count] > 0);
    }
    
    if ([indexes count] == 0 && failureMessage != NULL) {
        *failureMessage = [NSString stringWithFormat:@"Expected a call to -[%@ %@] but no such call was made",
                           prototype.invocation.target, NSStringFromSelector(prototype.invocation.selector)];
    }
    
    return (([indexes count] > 0) ? [NSIndexSet indexSetWithIndex:[indexes firstIndex]] : [NSIndexSet indexSet]);
}

@end
