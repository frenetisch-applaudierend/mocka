//
//  MCKInvocationVerifier.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKInvocationVerifier.h"

#import "MCKMockingContext.h"
#import "MCKInvocationRecorder.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKVerificationResultCollector.h"


@interface MCKInvocationVerifier ()

@property (nonatomic, strong) MCKInvocationRecorder *invocationRecorder;
@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, strong) id<MCKVerificationResultCollector> collector;

@end


@implementation MCKInvocationVerifier

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        [self reset];
    }
    return self;
}

- (void)reset {
    self.invocationRecorder = nil;
    self.collector = nil;
    self.verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
}


#pragma mark - Verification

- (void)beginVerificationWithInvocationRecorder:(MCKInvocationRecorder *)invocationRecorder {
    self.invocationRecorder = invocationRecorder;
}

- (void)useVerificationHandler:(id<MCKVerificationHandler>)verificationHandler {
    NSParameterAssert(verificationHandler != nil);
    self.verificationHandler = verificationHandler;
}

- (void)verifyInvocationsForPrototype:(MCKInvocationPrototype *)prototype {
    MCKVerificationResult *result = [self resultForInvocationPrototype:prototype];
    
    if ([self isInGroupVerification]) {
        [self collectResult:result];
    } else {
        [self processResult:result];
    }
    
    self.verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
}


#pragma mark - Group Verification

- (void)startGroupVerificationWithCollector:(id<MCKVerificationResultCollector>)collector {
    self.collector = collector;
    [collector beginCollectingResultsWithInvocationRecorder:self.invocationRecorder];
}

- (void)finishGroupVerification {
    NSAssert([self isInGroupVerification], @"Called while not in group verification");
    
    MCKVerificationResult *collectedResult = [self.collector finishCollectingResults];
    [self processResult:collectedResult];
}
        
- (BOOL)isInGroupVerification {
    return (self.collector != nil);
}

- (void)collectResult:(MCKVerificationResult *)result {
    MCKVerificationResult *collectedResult = [self.collector collectVerificationResult:result];
    if (![collectedResult isSuccess]) {
        [self notifyFailureWithResult:collectedResult];
    }
}


#pragma mark - Verification Primitives

- (MCKVerificationResult *)resultForInvocationPrototype:(MCKInvocationPrototype *)prototype {
    MCKVerificationResult *result = [self currentResultForPrototype:prototype];
    
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:self.timeout];
    while ([self mustProcessTimeoutForResult:result] && [self didNotYetReachDate:lastDate]) {
        [self.delegate invocationVerifierWillProcessTimeout:self];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:lastDate];
        [self.delegate invocationVerifierDidProcessTimeout:self];
        result = [self currentResultForPrototype:prototype];
    }
    return result;
}

- (MCKVerificationResult *)currentResultForPrototype:(MCKInvocationPrototype *)prototype {
    return [self.verificationHandler verifyInvocations:self.invocationRecorder.recordedInvocations forPrototype:prototype];
}

- (BOOL)mustProcessTimeoutForResult:(MCKVerificationResult *)result {
    if (self.timeout <= 0.0) { return NO; }
    
    return ([result isSuccess]
            ? [self.verificationHandler mustAwaitTimeoutForFailure]
            : ![self.verificationHandler failsFastDuringTimeout]);
}

- (BOOL)didNotYetReachDate:(NSDate *)lastDate {
    return ([lastDate laterDate:[NSDate date]] == lastDate);
}

- (void)processResult:(MCKVerificationResult *)result {
    if (result != nil) {
        [self.invocationRecorder removeInvocationsAtIndexes:result.matchingIndexes];
        if (![result isSuccess]) {
            [self notifyFailureWithResult:result];
        }
    }
    [self notifyFinish];
    [self reset];
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
