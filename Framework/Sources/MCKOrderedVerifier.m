//
//  MCKOrderedVerifier.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKOrderedVerifier.h"

#import "MCKDefaultVerifier.h"
#import "MCKInvocationPrototype.h"
#import "MCKVerificationHandler.h"
#import "MCKArgumentMatcherCollection.h"
#import "MCKFailureHandler.h"


@implementation MCKOrderedVerifier

@synthesize verificationHandler = _verificationHandler;
@synthesize failureHandler = _failureHandler;


#pragma mark - Verifying

- (MCKContextMode)verifyPrototype:(MCKInvocationPrototype *)prototype invocations:(NSMutableArray *)invocations {
    BOOL satisified = NO;
    NSString *reason = nil;
    
    NSRange relevantRange = NSMakeRange(_skippedInvocations, ([invocations count] - _skippedInvocations));
    NSArray *relevantInvocations = [invocations subarrayWithRange:relevantRange];
    NSIndexSet *matchingIndexes = [_verificationHandler indexesOfInvocations:relevantInvocations
                                                        matchingForPrototype:prototype
                                                                   satisfied:&satisified
                                                              failureMessage:&reason];
    
    if (!satisified) {
        NSString *message = [NSString stringWithFormat:@"verify: %@", (reason != nil ? reason : @"failed with an unknown reason")];
        [_failureHandler handleFailureWithReason:message];
    }
    
    [self removeMatchingIndexes:matchingIndexes fromRecordedInvocations:invocations];
    
    if ([matchingIndexes count] > 0) {
        _skippedInvocations += ([matchingIndexes lastIndex] - [matchingIndexes count] + 1);
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


@implementation MCKMockingContext (MCKOrderedVerification)

- (void (^)())inOrderBlock {
    NSAssert(NO, @"The inOrderBlock property is only for internal use and cannot be read");
    return nil;
}

- (void)setInOrderBlock:(void (^)())inOrderBlock {
    [self verifyInOrder:inOrderBlock];
}

- (void)verifyInOrder:(void (^)())verifications {
    NSParameterAssert(verifications != nil);
    [self setVerifier:[[MCKOrderedVerifier alloc] init]];
    verifications();
    [self setVerifier:[[MCKDefaultVerifier alloc] init]];
    [self updateContextMode:MCKContextModeRecording];
}

@end

