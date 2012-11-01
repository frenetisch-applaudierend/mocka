//
//  MCKInvocationVerifier.h
//  mocka
//
//  Created by Markus Gasser on 01.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKMockingContext.h"

@class MCKInvocationRecorder;
@protocol MCKFailureHandler;
@protocol MCKVerificationHandler;


@protocol MCKInvocationVerifier <NSObject>

@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;

/** Check if the invocation can be verified given the recorded invocations.
 * If the verification succeeds, the caller should remove matching invocations as appropriate. If it fails, the failure should be reported to the
 * passed failureHandler.
 */
- (void)verifyInvocation:(NSInvocation *)invocation inRecorder:(MCKInvocationRecorder *)recorder failureHandler:(id<MCKFailureHandler>)failureHandler;

/** Specifies which mode the context should swap to after verifying a method call using this verifier.
 * This method is always called directly after a call to -verifyInvocation:inRecorder:failureHandler: and is only called once.
 */
- (MCKContextMode)nextContextMode;

@end
