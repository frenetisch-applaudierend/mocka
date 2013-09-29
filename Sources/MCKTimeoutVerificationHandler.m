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


@interface MCKTimeoutVerificationHandler ()

@property (nonatomic, readonly) NSTimeInterval timeout;
@property (nonatomic, readonly) id<MCKVerificationHandler> previousHandler;

@end

@implementation MCKTimeoutVerificationHandler

#pragma mark - Initialization

+ (instancetype)timeoutHandlerWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler {
    return [[self alloc] initWithTimeout:timeout currentVerificationHandler:handler];
}

- (instancetype)initWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler {
    if ((self = [super init])) {
        _timeout = timeout;
        _previousHandler = handler;
    }
    return self;
}


#pragma mark - Verifying Invocations

- (MCKVerificationResult *)verifyInvocations:(NSArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype {
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:self.timeout];
    BOOL expectSuccess = ![self.previousHandler isKindOfClass:[MCKNeverVerificationHandler class]];
    
    MCKVerificationResult *result;
    do {
        result = [self.previousHandler verifyInvocations:invocations forPrototype:prototype];
    } while ((result.success != expectSuccess) && [self processRecordingInputIfBefore:lastDate]);
    return result;
}


#pragma mark - Handling Waiting for timeout

- (BOOL)processRecordingInputIfBefore:(NSDate *)lastDate {
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
