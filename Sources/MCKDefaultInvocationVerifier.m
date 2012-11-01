//
//  MCKDefaultInvocationVerifier.m
//  mocka
//
//  Created by Markus Gasser on 31.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKDefaultInvocationVerifier.h"

@implementation MCKDefaultInvocationVerifier

@synthesize verificationHandler = _verificationHandler;


- (void)verifyInvocation:(NSInvocation *)invocation inRecorder:(MCKInvocationRecorder *)recorder failureHandler:(id<MCKFailureHandler>)failureHandler {
    
}

- (MCKContextMode)nextContextMode {
    return MCKContextModeRecording;
}

@end
