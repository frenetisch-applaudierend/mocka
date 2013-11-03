//
//  MCKInvocationVerifier.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKInvocationVerifier.h"

#import "MCKMockingContext.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKVerificationResultCollector.h"


@interface MCKInvocationVerifier ()

@property (nonatomic, strong) id<MCKVerificationResultCollector> collector;
@property (nonatomic, strong) NSMutableArray *invocations;

@end


@implementation MCKInvocationVerifier

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
    }
    return self;
}


#pragma mark - Verifying

- (void)verifyInvocations:(NSMutableArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype {
    MCKVerificationResult *result = [self resultForInvocations:invocations prototype:prototype];
    
    if (self.collector != nil) {
        [self collectResult:result forInvocations:invocations];
    } else {
        [self processResult:result forInvocations:invocations];
    }
    self.verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
}

- (void)collectResult:(MCKVerificationResult *)result forInvocations:(NSMutableArray *)invocations {
    MCKVerificationResult *collectedResult = [self.collector collectVerificationResult:result forInvocations:invocations];
    self.invocations = invocations;
    if (![collectedResult isSuccess]) {
        [self notifyFailureWithResult:collectedResult];
    }
}

- (void)processResult:(MCKVerificationResult *)result forInvocations:(NSMutableArray *)invocations {
    if (result != nil) {
        [invocations removeObjectsAtIndexes:result.matchingIndexes];
        if (![result isSuccess]) {
            [self notifyFailureWithResult:result];
        }
    }
    [self notifyFinish];
}

- (MCKVerificationResult *)resultForInvocations:(NSArray *)invocations prototype:(MCKInvocationPrototype *)prototype {
    MCKVerificationResult *result = [self.verificationHandler verifyInvocations:invocations forPrototype:prototype];
    
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:self.timeout];
    while ([self mustProcessTimeoutForResult:result] && [self didNotYetReachDate:lastDate]) {
        [self.delegate invocationVerifierWillProcessTimeout:self];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:lastDate];
        [self.delegate invocationVerifierDidProcessTimeout:self];
        result = [self.verificationHandler verifyInvocations:invocations forPrototype:prototype];
    }
    return result;
}

- (BOOL)mustProcessTimeoutForResult:(MCKVerificationResult *)result {
    if (self.timeout <= 0.0) { return NO; }
    
    if ([result isSuccess]) {
        return [self.verificationHandler mustAwaitTimeoutForFailure];
    } else {
        return ![self.verificationHandler failsFastDuringTimeout];
    }
}

- (BOOL)didNotYetReachDate:(NSDate *)lastDate {
    return ([lastDate laterDate:[NSDate date]] == lastDate);
}


#pragma mark - Group Recording

- (void)beginGroupRecordingWithCollector:(id<MCKVerificationResultCollector>)collector {
    self.collector = collector;
}

- (void)finishGroupRecording {
    NSAssert(self.collector != nil, @"Finish called without collector");
    
    MCKVerificationResult *collectedResult = [self.collector processCollectedResultsWithInvocations:self.invocations];
    [self processResult:collectedResult forInvocations:nil];
    self.invocations = nil;
    self.collector = nil;
}


#pragma mark - Notifications

- (void)notifyFailureWithResult:(MCKVerificationResult *)result {
    NSString *reason = [NSString stringWithFormat:@"verify: %@", (result.failureReason ?: @"failed with an unknown reason")];
    [self.delegate invocationVerifier:self didFailWithReason:reason];
}

- (void)notifyFinish {
    [self.delegate invocationVerifierDidEnd:self];
}

@end
