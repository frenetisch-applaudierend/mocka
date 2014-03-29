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
#import "MCKVerificationGroup.h"

#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKVerificationResultCollector.h"


@interface MCKInvocationVerifier ()

@property (nonatomic, readonly) NSMutableArray *currentVerificationGroups;
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
        _currentVerificationGroups = [NSMutableArray array];
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
    
    if (self.currentVerificationGroup != nil) {
        result = [self.currentVerificationGroup collectResult:result];
        if ([result isFailure]) {
            [self.mockingContext.failureHandler handleFailureAtLocation:verification.location withReason:result.failureReason];
        }
    }
    else {
        [self.mockingContext.invocationRecorder removeInvocationsAtIndexes:result.matchingIndexes];
        if ([result isFailure]) {
            [self.mockingContext.failureHandler handleFailureAtLocation:verification.location withReason:result.failureReason];
        }
    }
}

- (void)processVerificationGroup:(MCKVerificationGroup *)verificationGroup
{
    NSParameterAssert(verificationGroup != nil);
    
    [self pushVerificationGroup:verificationGroup];
    MCKVerificationResult *result = [verificationGroup executeWithInvocationRecorder:self.mockingContext.invocationRecorder];
    [self popVerificationGroup];
    
    if (result != nil) {
        [self.mockingContext.invocationRecorder removeInvocationsAtIndexes:result.matchingIndexes];
        if ([result isFailure]) {
            [self.mockingContext.failureHandler handleFailureAtLocation:verificationGroup.location withReason:result.failureReason];
        }
    }
}

- (void)verifyInvocationsForPrototype:(MCKInvocationPrototype *)prototype
{
    [self.currentVerification verifyPrototype:prototype inInvocationRecorder:self.mockingContext.invocationRecorder];
}


#pragma mark - Managing the Verification Group Stack

- (MCKVerificationGroup *)currentVerificationGroup
{
    return [self.currentVerificationGroups lastObject];
}

- (void)pushVerificationGroup:(MCKVerificationGroup *)verificationGroup
{
    [self.currentVerificationGroups addObject:verificationGroup];
}

- (void)popVerificationGroup
{
    [self.currentVerificationGroups removeLastObject];
}

@end
