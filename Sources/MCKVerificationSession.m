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
#import <Mocka/MCKVerificationResultCollector.h>


@interface MCKVerificationSession ()

@property (nonatomic, strong) id<MCKVerificationResultCollector> collector;
@property (nonatomic, strong) NSMutableArray *collectedResults;
@property (nonatomic, strong) NSMutableArray *preservedInvocations;

@end


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
    
    if (self.collector != nil) {
        [self collectResult:result forInvocations:invocations];
    } else {
        [self processResult:result forInvocations:invocations];
    }
    self.verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
}

- (void)collectResult:(MCKVerificationResult *)result forInvocations:(NSMutableArray *)invocations {
    [self.collectedResults addObject:result];
    self.preservedInvocations = invocations;
}

- (void)processResult:(MCKVerificationResult *)result forInvocations:(NSMutableArray *)invocations {
    [invocations removeObjectsAtIndexes:result.matchingIndexes];
    if (![result isSuccess]) {
        [self notifyFailureWithResult:result];
    }
    [self notifyFinish];
}


#pragma mark - Group Recording

- (void)beginGroupRecordingWithCollector:(id<MCKVerificationResultCollector>)collector {
    self.collector = collector;
    self.collectedResults = [NSMutableArray array];
}

- (void)finishGroupRecording {
    NSAssert(self.collector != nil, @"Finish called without collector");
    
    MCKVerificationResult *mergedResult = [self.collector resultByMergingResults:self.collectedResults];
    if (mergedResult == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"merged result cannot be nil" userInfo:nil];
    }
    
    [self processResult:mergedResult forInvocations:self.preservedInvocations];
    self.preservedInvocations = nil;
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
