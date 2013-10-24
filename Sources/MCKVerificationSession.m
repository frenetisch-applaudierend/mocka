//
//  MCKVerificationSession.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKVerificationSession.h"

#import "MCKMockingContext.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKVerificationResultCollector.h"


@interface MCKVerificationSession ()

@property (nonatomic, strong) id<MCKVerificationResultCollector> collector;
@property (nonatomic, strong) NSMutableArray *invocations;

@end


@implementation MCKVerificationSession

#pragma mark - Initialization

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    if ((self = [super init])) {
        _timeout = timeout;
        _verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
    }
    return self;
}

- (instancetype)init {
    return [self initWithTimeout:0.0];
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
        [self.delegate verificationSessionWillProcessTimeout:self];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:lastDate];
        [self.delegate verificationSessionDidProcessTimeout:self];
        result = [self.verificationHandler verifyInvocations:invocations forPrototype:prototype];
    }
    return result;
}

- (BOOL)mustProcessTimeoutForResult:(MCKVerificationResult *)result {
    return (self.timeout > 0.0 && (![result isSuccess] || [self.verificationHandler mustAwaitTimeoutForFailure]));
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
    [self.delegate verificationSession:self didFailWithReason:reason];
}

- (void)notifyFinish {
    [self.delegate verificationSessionDidEnd:self];
}

@end
