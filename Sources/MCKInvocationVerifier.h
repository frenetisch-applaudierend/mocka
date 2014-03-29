//
//  MCKInvocationVerifier.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKInvocationVerifierDelegate;
@protocol MCKVerificationResultCollector;
@protocol MCKVerificationHandler;

@class MCKMockingContext;
@class MCKInvocationPrototype;
@class MCKVerification;
@class MCKVerificationGroup;


@interface MCKInvocationVerifier : NSObject

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context;

@property (nonatomic, readonly, weak) MCKMockingContext *mockingContext;


#pragma mark - Verification

@property (nonatomic, readonly) MCKVerificationGroup *currentVerificationGroup;
@property (nonatomic, readonly) MCKVerification *currentVerification;

- (void)processVerification:(MCKVerification *)verification;
- (void)processVerificationGroup:(MCKVerificationGroup *)verificationGroup;

- (void)verifyInvocationsForPrototype:(MCKInvocationPrototype *)prototype;

@end
