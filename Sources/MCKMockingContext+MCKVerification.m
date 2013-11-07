//
//  MCKMockingContext+MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext+MCKVerification.h"
#import "MCKMockingContext+MCKFailureHandling.h"

#import "MCKInvocationRecorder.h"
#import "MCKInvocationVerifier.h"
#import "MCKArgumentMatcherRecorder.h"
#import "MCKInvocationPrototype.h"


@implementation MCKMockingContext (MCKVerification)

- (void)beginVerificationWithTimeout:(NSTimeInterval)timeout {
    [self.invocationVerifier beginVerificationWithInvocationRecorder:self.invocationRecorder];
    self.invocationVerifier.timeout = timeout;
    [self updateContextMode:MCKContextModeVerifying];
}

- (void)endVerification {
    [self updateContextMode:MCKContextModeRecording];
}

- (void)suspendVerification {
    [self updateContextMode:MCKContextModeRecording];
}

- (void)resumeVerification {
    [self updateContextMode:MCKContextModeVerifying];
}

- (void)useVerificationHandler:(id<MCKVerificationHandler>)handler {
    NSAssert((self.mode == MCKContextModeVerifying), @"Cannot set a verification handler outside verification mode");
    [self.invocationVerifier useVerificationHandler:handler];
}

- (void)verifyInvocation:(NSInvocation *)invocation {
    NSArray *matchers = [self.argumentMatcherRecorder collectAndReset];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
    [self.invocationVerifier verifyInvocationsForPrototype:prototype];
}

- (void)invocationVerifier:(MCKInvocationVerifier *)verififer didFailWithReason:(NSString *)reason {
    [self failWithReason:@"%@", (reason ?: @"")];
}

- (void)invocationVerifierDidEnd:(MCKInvocationVerifier *)verififer {
    [self endVerification];
}

- (void)invocationVerifierWillProcessTimeout:(MCKInvocationVerifier *)verififer {
    [self suspendVerification];
}

- (void)invocationVerifierDidProcessTimeout:(MCKInvocationVerifier *)verififer {
    [self resumeVerification];
}

@end
