//
//  MCKVerificationSession.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKVerificationSession.h"

#import <Mocka/MCKVerificationHandler.h>
#import <Mocka/MCKDefaultVerificationHandler.h>


@implementation MCKVerificationSession

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
    }
    return self;
}


#pragma mark - Verifying

- (void)verifyInvocations:(NSMutableArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype {
    MCKVerificationResult *result = [self.verificationHandler verifyInvocations:invocations forPrototype:prototype];
    
    [invocations removeObjectsAtIndexes:result.matchingIndexes];
    self.verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
    
    if (![result isSuccess]) {
        [self notifyFailureWithResult:result];
    }
    [self notifyFinish];
}

- (void)notifyFailureWithResult:(MCKVerificationResult *)result {
    NSString *reason = [NSString stringWithFormat:@"verify: %@", (result.failureReason ?: @"failed with an unknown reason")];
    [self.delegate verificationSession:self didFailWithReason:reason];
}

- (void)notifyFinish {
    [self.delegate verificationSessionDidEnd:self];
}


#pragma mark - Group Recording

- (void)beginGroupRecordingWithCollector:(id<MCKVerificationResultCollector>)collector {
}

- (void)finishGroupRecording {
}

@end
