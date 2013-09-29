//
//  MCKTimeoutVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKTimeoutVerificationHandler.h"
#import "MCKNeverVerificationHandler.h"
#import "MCKMockingContext.h"
#import "MCKMockObject.h"
#import <objc/runtime.h>


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

- (NSIndexSet *)indexesOfInvocations:(NSArray *)invocations
                matchingForPrototype:(MCKInvocationPrototype *)prototype
                           satisfied:(BOOL *)satisified
                      failureMessage:(NSString **)failureMessage
{
    BOOL internalSatisfied = NO;
    NSString *internalFailureMessage = nil;
    NSIndexSet *indices = nil;
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:_timeout];
    BOOL expectedResult = ![_previousHandler isKindOfClass:[MCKNeverVerificationHandler class]];
    
    do {
        indices = [_previousHandler indexesOfInvocations:invocations
                                    matchingForPrototype:prototype
                                               satisfied:&internalSatisfied
                                          failureMessage:&internalFailureMessage];
    } while ((internalSatisfied != expectedResult) && [self processRecordingInputIfBefore:lastDate]);
    
    if (satisified != NULL) { *satisified = internalSatisfied; }
    if (failureMessage != NULL) { *failureMessage = [internalFailureMessage copy]; }
    return indices;
}


#pragma mark - Handling Waiting for timeout

- (BOOL)processRecordingInputIfBefore:(NSDate *)lastDate {
    return NO;
//    if ([[NSDate date] laterDate:lastDate] != lastDate) {
//        return NO;
//    }
//    
//    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeRecording];
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
//    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeVerifying];
//    [[MCKMockingContext currentContext] setVerificationHandler:self];
//    return YES;
}

@end


#pragma mark - Signaling

@interface MCKSignaler : NSObject
@end

@implementation MCKSignaler

- (void)giveSignal:(NSString *)signal {}

+ (id)signalerForContext:(MCKMockingContext *)context {
    NSParameterAssert(context != nil);
    static NSString *SignalerKey = @"signaler";
    
    MCKSignaler *signaler = objc_getAssociatedObject(context, &SignalerKey);
    if (signaler == nil) {
        signaler = [MCKMockObject mockWithContext:context classAndProtocols:@[ [self class] ]];
        objc_setAssociatedObject(context, &SignalerKey, signaler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return signaler;
}

@end


void _mck_issueSignalInternal(NSString *signal) {
    NSCParameterAssert(signal != nil);
    [[MCKSignaler signalerForContext:[MCKMockingContext currentContext]] giveSignal:signal];
}
