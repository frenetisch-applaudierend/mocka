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
#import "MCKFailureHandler.h"
#import "MCKVerification.h"

#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKVerificationResultCollector.h"


@interface MCKInvocationVerifier ()

@property (nonatomic, strong) MCKVerification *currentVerification;
@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, strong) id<MCKVerificationResultCollector> collector;

@end


@implementation MCKInvocationVerifier

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
{
    if ((self = [super init])) {
        _mockingContext = context;
    }
    return self;
}


#pragma mark - Verification

- (void)processVerification:(MCKVerification *)verification
{
    NSParameterAssert(verification != nil);
    NSAssert(self.currentVerification == nil, @"Another verification is already running");
    
    self.currentVerification = verification;
    MCKVerificationResult *result = [verification execute];
    self.currentVerification = nil;
    
    [self.mockingContext.invocationRecorder removeInvocationsAtIndexes:result.matchingIndexes];
    
    if ([result isFailure]) {
        [self.mockingContext.failureHandler handleFailureAtLocation:verification.location withReason:result.failureReason];
    }
}

- (void)verifyInvocationsForPrototype:(MCKInvocationPrototype *)prototype
{
    if (self.currentVerification != nil) {
        NSArray *invocations = self.mockingContext.invocationRecorder.recordedInvocations;
        [self.currentVerification verifyInvocations:invocations forPrototype:prototype];
        return;
    }
    
    MCKVerificationResult *result = [self resultForInvocationPrototype:prototype];
    MCKVerificationResult *collectedResult = [self.collector collectVerificationResult:result];
    
    if ([collectedResult isFailure]) {
        [self notifyFailureWithResult:collectedResult];
    }
    
    self.verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
    self.timeout = 0.0;
}

- (void)beginVerificationWithCollector:(id<MCKVerificationResultCollector>)collector
{
    self.collector = collector;
    self.verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
    
    [collector beginCollectingResultsWithInvocationRecorder:self.mockingContext.invocationRecorder];
}

- (void)useVerificationHandler:(id<MCKVerificationHandler>)verificationHandler
{
    NSParameterAssert(verificationHandler != nil);
    self.verificationHandler = verificationHandler;
}

- (void)finishVerification
{
    MCKVerificationResult *collectedResult = [self.collector finishCollectingResults];
    
    if (collectedResult != nil) {
        [self.mockingContext.invocationRecorder removeInvocationsAtIndexes:collectedResult.matchingIndexes];
        if ([collectedResult isFailure]) {
            [self notifyFailureWithResult:collectedResult];
        }
    }
    
    self.collector = nil;
    self.verificationHandler = nil;
}


#pragma mark - Verification Primitives

- (MCKVerificationResult *)resultForInvocationPrototype:(MCKInvocationPrototype *)prototype
{
    MCKVerificationResult *result = [self currentResultForPrototype:prototype];
    
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:self.timeout];
    while ([self mustProcessTimeoutForResult:result] && [self didNotYetReachDate:lastDate]) {
        [self.mockingContext updateContextMode:MCKContextModeRecording];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:lastDate];
        [self.mockingContext updateContextMode:MCKContextModeVerifying];
        result = [self currentResultForPrototype:prototype];
    }
    return result;
}

- (MCKVerificationResult *)currentResultForPrototype:(MCKInvocationPrototype *)prototype
{
    NSArray *recordedInvocations = self.mockingContext.invocationRecorder.recordedInvocations;
    return [self.verificationHandler verifyInvocations:recordedInvocations forPrototype:prototype];
}

- (BOOL)mustProcessTimeoutForResult:(MCKVerificationResult *)result
{
    if (self.timeout <= 0.0) {
        return NO;
    }
    else {
        return [self.verificationHandler mustAwaitTimeoutForResult:result];
    }
}

- (BOOL)didNotYetReachDate:(NSDate *)lastDate
{
    return ([lastDate laterDate:[NSDate date]] == lastDate);
}


#pragma mark - Notifications

- (void)notifyFailureWithResult:(MCKVerificationResult *)result
{
    NSString *reason = [NSString stringWithFormat:@"verify: %@", (result.failureReason ?: @"failed with an unknown reason")];
    [self.mockingContext failWithReason:@"%@", reason];
}

@end
