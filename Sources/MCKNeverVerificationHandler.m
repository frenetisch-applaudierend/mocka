//
//  MCKNeverVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKNeverVerificationHandler.h"
#import "MCKArgumentMatcherCollection.h"


@implementation MCKNeverVerificationHandler

#pragma mark - Initialization

+ (id)neverHandler {
    return [[self alloc] init];
}


#pragma mark - Matching Invocations

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)matchers
                    inRecordedInvocations:(MCKInvocationCollection *)recordedInvocations
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [recordedInvocations invocationsMatchingPrototype:prototype withArgumentMatchers:matchers];
    
    if (satisified != NULL) {
        *satisified = ([indexes count] == 0);
    }
    
    if ([indexes count] > 0 && failureMessage != NULL) {
        *failureMessage = [NSString stringWithFormat:@"Expected no calls to -[%@ %@] but got %ld",
                           prototype.target, NSStringFromSelector(prototype.selector), (unsigned long)[indexes count]];
    }
    
    return [NSIndexSet indexSet];
}

@end
