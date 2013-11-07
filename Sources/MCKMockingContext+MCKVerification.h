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

- (void)verifyInvocation:(NSInvocation *)invocation;

- (void)beginVerificationWithTimeout:(NSTimeInterval)timeout;
- (void)endVerification;

- (void)suspendVerification;
- (void)resumeVerification;

- (void)useVerificationHandler:(id<MCKVerificationHandler>)handler;

@end
