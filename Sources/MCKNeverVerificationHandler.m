//
//  MCKNeverVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKNeverVerificationHandler.h"

#import "MCKInvocationPrototype.h"
#import "MCKArgumentMatcherCollection.h"
#import "MCKArgumentMatcherCollection.h"


@implementation MCKNeverVerificationHandler

#pragma mark - Initialization

+ (id)neverHandler {
    return [[self alloc] init];
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
        *satisified = ([indexes count] == 0);
    }
    
    if ([indexes count] > 0 && failureMessage != NULL) {
        *failureMessage = [NSString stringWithFormat:@"Expected no calls to -[%@ %@] but got %ld",
                           prototype.invocation.target,
                           NSStringFromSelector(prototype.invocation.selector),
                           (unsigned long)[indexes count]];
    }
    
    return [NSIndexSet indexSet];
}

@end
