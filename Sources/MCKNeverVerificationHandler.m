//
//  MCKNeverVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKNeverVerificationHandler.h"
#import "MCKInvocationMatcher.h"
#import "MCKInvocationRecorder.h"
#import "MCKArgumentMatcherCollection.h"


@implementation MCKNeverVerificationHandler

#pragma mark - Initialization

+ (id)neverHandler {
    return [[self alloc] init];
}


#pragma mark - Matching Invocations

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)matchers
                     inInvocationRecorder:(MCKInvocationRecorder *)recorder
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [recorder invocationsMatchingPrototype:prototype withPrimitiveArgumentMatchers:matchers.primitiveArgumentMatchers];
    
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
