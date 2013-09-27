//
//  FakeVerifier.m
//  mocka
//
//  Created by Markus Gasser on 16.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "FakeVerifier.h"


@implementation FakeVerifier {
    MCKContextMode _contextMode;
}

@synthesize verificationHandler = _verificationHandler;
@synthesize failureHandler = _failureHandler;


#pragma mark - Initialization

- (id)initWithNewContextMode:(MCKContextMode)mode {
    if ((self = [super init])) {
        _contextMode = mode;
    }
    return self;
}

- (id)init {
    return [self initWithNewContextMode:MCKContextModeRecording];
}


#pragma mark - Verifying

- (MCKContextMode)verifyInvocation:(NSInvocation *)invocation
                      withMatchers:(MCKArgumentMatcherCollection *)matchers
             inRecordedInvocations:(NSMutableArray *)recordedInvocations
{
    _lastPassedInvocation = invocation;
    _lastPassedMatchers = matchers;
    _lastPassedRecordedInvocations = recordedInvocations;
    return _contextMode;
}

@end
