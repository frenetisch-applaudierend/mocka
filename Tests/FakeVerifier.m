//
//  FakeVerifier.m
//  mocka
//
//  Created by Markus Gasser on 16.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "FakeVerifier.h"
#import "MCKInvocationPrototype.h"


@implementation FakeVerifier {
    MCKContextMode _contextMode;
}

@synthesize verificationHandler = _verificationHandler;
@synthesize failureHandler = _failureHandler;


#pragma mark - Initialization

- (instancetype)initWithNewContextMode:(MCKContextMode)mode {
    if ((self = [super init])) {
        _contextMode = mode;
    }
    return self;
}

- (instancetype)init {
    return [self initWithNewContextMode:MCKContextModeRecording];
}


#pragma mark - Verifying

- (MCKContextMode)verifyPrototype:(MCKInvocationPrototype *)prototype invocations:(NSMutableArray *)invocations {
    _lastPassedInvocation = prototype.invocation;
    _lastPassedMatchers = prototype.argumentMatchers;
    _lastPassedRecordedInvocations = invocations;
    return _contextMode;
}

@end
