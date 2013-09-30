//
//  MCKOrderedVerifier.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKOrderedVerifier.h"

#import <Mocka/MCKInvocationPrototype.h>
#import <Mocka/MCKVerificationHandler.h>

#import "MCKDefaultVerifier.h"
#import "MCKFailureHandler.h"


@implementation MCKOrderedVerifier

@synthesize verificationHandler = _verificationHandler;
@synthesize failureHandler = _failureHandler;


#pragma mark - Verifying

- (MCKContextMode)verifyPrototype:(MCKInvocationPrototype *)prototype invocations:(NSMutableArray *)invocations {
    NSRange relevantRange = NSMakeRange(_skippedInvocations, ([invocations count] - _skippedInvocations));
    NSArray *relevantInvocations = [invocations subarrayWithRange:relevantRange];
    MCKVerificationResult *result = [_verificationHandler verifyInvocations:relevantInvocations forPrototype:prototype];
    
    if (![result isSuccess]) {
        NSString *message = [NSString stringWithFormat:@"verify: %@", (result.failureReason ?: @"failed with an unknown reason")];
        [_failureHandler handleFailureWithReason:message];
    }
    
    [self removeMatchingIndexes:result.matchingIndexes fromRecordedInvocations:invocations];
    if ([result.matchingIndexes count] > 0) {
        _skippedInvocations += ([result.matchingIndexes lastIndex] - [result.matchingIndexes count] + 1);
    }
    return MCKContextModeVerifying;
}

- (void)removeMatchingIndexes:(NSIndexSet *)indexes fromRecordedInvocations:(NSMutableArray *)recordedInvocations {
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [toRemove addIndex:idx + _skippedInvocations];
    }];
    [recordedInvocations removeObjectsAtIndexes:toRemove];
}

@end
