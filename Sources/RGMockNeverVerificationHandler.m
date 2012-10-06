//
//  RGMockNeverVerificationHandler.m
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockNeverVerificationHandler.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockNeverVerificationHandler

#pragma mark - Initialization

+ (id)neverHandler {
    return [[self alloc] init];
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
        *satisified = ([indexes count] == 0);
    }
    
    if ([indexes count] > 0 && failureMessage != NULL) {
        *failureMessage = [NSString stringWithFormat:@"Expected no calls to -[%@ %@] but got %ld",
                           prototype.target, NSStringFromSelector(prototype.selector), (unsigned long)[indexes count]];
    }
    
    return [NSIndexSet indexSet];
}

@end
