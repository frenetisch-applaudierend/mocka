//
//  MCKTimeoutVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKTimeoutVerificationHandler.h"


@implementation MCKTimeoutVerificationHandler {
    NSTimeInterval _timeout;
    id<MCKVerificationHandler> _previousHandler;
}

#pragma mark - Initialization

+ (id)timeoutHandlerWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler {
    return [[self alloc] initWithTimeout:timeout currentVerificationHandler:handler];
}

- (id)initWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler {
    if ((self = [super init])) {
        _timeout = timeout;
        _previousHandler = handler;
    }
    return self;
}


#pragma mark - Handling Verification

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)matchers
                    inRecordedInvocations:(MCKInvocationCollection *)recordedInvocations
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    BOOL internalSatisfied = NO;
    NSString *internalFailureMessage = nil;
    NSIndexSet *indices = nil;
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:_timeout];
    
    do {
        indices = [_previousHandler indexesMatchingInvocation:prototype
                                         withArgumentMatchers:matchers
                                        inRecordedInvocations:recordedInvocations
                                                    satisfied:&internalSatisfied
                                               failureMessage:&internalFailureMessage];
    } while (!internalSatisfied && [self processNormalInput:lastDate]);
    
    if (satisified != NULL) { *satisified = internalSatisfied; }
    if (failureMessage != NULL) { *failureMessage = [internalFailureMessage copy]; }
    return indices;
}

- (BOOL)processNormalInput:(NSDate *)lastDate {
    if ([[NSDate date] laterDate:lastDate] != lastDate) {
        return NO;
    }
    
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeRecording];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeVerifying];
    [[MCKMockingContext currentContext] setVerificationHandler:self];
    return YES;
}

@end
