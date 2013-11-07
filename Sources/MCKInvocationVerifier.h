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

@class MCKInvocationRecorder;
@class MCKInvocationPrototype;


@interface MCKInvocationVerifier : NSObject

#pragma mark - Configuration

@property (nonatomic, weak) id<MCKInvocationVerifierDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeout; // reset to 0.0 after each verified call
@property (nonatomic, readonly) id<MCKVerificationHandler> verificationHandler;


#pragma mark - Verification

- (void)beginVerificationWithInvocationRecorder:(MCKInvocationRecorder *)invocationRecorder;
- (void)useVerificationHandler:(id<MCKVerificationHandler>)verificationHandler;
- (void)verifyInvocationsForPrototype:(MCKInvocationPrototype *)prototype;


#pragma mark - Group Verification

- (void)startGroupVerificationWithCollector:(id<MCKVerificationResultCollector>)collector;
- (void)finishGroupVerification;
- (BOOL)isInGroupVerification;

@end


@protocol MCKInvocationVerifierDelegate <NSObject>

- (void)invocationVerifier:(MCKInvocationVerifier *)verififer didFailWithReason:(NSString *)reason;
- (void)invocationVerifierDidEnd:(MCKInvocationVerifier *)verififer;

- (void)invocationVerifierWillProcessTimeout:(MCKInvocationVerifier *)verififer;
- (void)invocationVerifierDidProcessTimeout:(MCKInvocationVerifier *)verififer;

@end
