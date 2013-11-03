//
//  MCKMockingContext+MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"


@interface MCKMockingContext (MCKVerification) <MCKInvocationVerifierDelegate>

#pragma mark - Verifying

@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;

- (void)verifyInvocation:(NSInvocation *)invocation;

- (void)beginVerificationWithTimeout:(NSTimeInterval)timeout;
- (void)endVerification;

- (void)suspendVerification;
- (void)resumeVerification;

@end
