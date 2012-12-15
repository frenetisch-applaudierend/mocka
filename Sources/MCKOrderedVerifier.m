//
//  MCKOrderedVerifier.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKOrderedVerifier.h"
#import "MCKVerificationHandler.h"
#import "MCKFailureHandler.h"


@implementation MCKOrderedVerifier

@synthesize verificationHandler = _verificationHandler;
@synthesize failureHandler = _failureHandler;


#pragma mark - Verifying

- (MCKContextMode)verifyInvocation:(NSInvocation *)invocation
                      withMatchers:(MCKArgumentMatcherCollection *)matchers
             inRecordedInvocations:(MCKMutableInvocationCollection *)recordedInvocations
{
    BOOL satisified = NO;
    NSString *reason = nil;
    
    MCKInvocationCollection *relevantInvocations = [recordedInvocations subcollectionFromIndex:_skippedInvocations];
    NSIndexSet *matchingIndexes = [_verificationHandler indexesMatchingInvocation:invocation withArgumentMatchers:matchers
                                                            inRecordedInvocations:relevantInvocations
                                                                        satisfied:&satisified failureMessage:&reason];
    
    if (!satisified) {
        NSString *message = [NSString stringWithFormat:@"verify: %@", (reason != nil ? reason : @"failed with an unknown reason")];
        [_failureHandler handleFailureWithReason:message];
    }
    
    [self removeMatchingIndexes:matchingIndexes fromRecordedInvocations:recordedInvocations];
    
    _skippedInvocations += ([matchingIndexes lastIndex] - [matchingIndexes count] + 1);
    return MCKContextModeVerifying;
}

- (void)removeMatchingIndexes:(NSIndexSet *)indexes fromRecordedInvocations:(MCKMutableInvocationCollection *)recordedInvocations {
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [toRemove addIndex:idx + _skippedInvocations];
    }];
    [recordedInvocations removeInvocationsAtIndexes:toRemove];
}

@end
