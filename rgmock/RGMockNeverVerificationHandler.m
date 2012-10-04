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
            withNonObjectArgumentMatchers:(NSArray *)argumentMatchers
                    inRecordedInvocations:(NSArray *)recordedInvocations
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [recordedInvocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
        return [[RGMockInvocationMatcher defaultMatcher] invocation:candidate matchesPrototype:prototype withNonObjectArgumentMatchers:argumentMatchers];
    }];
    
    if (satisified != NULL) {
        *satisified = ([indexes count] == 0);
    }
    
    if ([indexes count] > 0 && failureMessage != NULL) {
        *failureMessage = [NSString stringWithFormat:@"Expected no calls to -[<%@ %p> %@] but got %d",
                           [prototype.target class], prototype.target, NSStringFromSelector(prototype.selector), [indexes count]];
    }
    
    return [NSIndexSet indexSet];
}

@end
