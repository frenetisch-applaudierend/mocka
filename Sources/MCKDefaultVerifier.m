//
//  MCKDefaultVerifier.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKDefaultVerifier.h"

#import "MCKVerificationHandler.h"
#import "MCKInvocationPrototype.h"
#import "MCKFailureHandler.h"


@implementation MCKDefaultVerifier

@synthesize verificationHandler = _verificationHandler;
@synthesize failureHandler = _failureHandler;


#pragma mark - Verifying

- (MCKContextMode)verifyPrototype:(MCKInvocationPrototype *)prototype invocations:(NSMutableArray *)invocations {
    MCKVerificationResult *result = [_verificationHandler verifyInvocations:invocations forPrototype:prototype];
    if (![result isSuccess]) {
        NSString *message = [NSString stringWithFormat:@"verify: %@", (result.failureReason ?: @"failed with an unknown reason")];
        [_failureHandler handleFailureWithReason:message];
    }
    [invocations removeObjectsAtIndexes:result.matchingIndexes];
    return MCKContextModeRecording;
}

@end
