//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 26.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerification.h"
#import "MCKMockingContext.h"
#import "MCKInvocationRecorder.h"
#import "MCKVerificationResult.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKAPIMisuse.h"


#define CONFIG_BLOCK_IMPL(NAME, TYPE, VAL)\
    @synthesize NAME = _ ## NAME;\
    - (MCKVerification *(^)(TYPE))NAME {\
        if (_ ## NAME == nil) {\
            __weak typeof(self) weakSelf = self;\
            _ ## NAME = ^(TYPE value) {\
                return [weakSelf update_ ## NAME:value];\
            };\
        }\
        return _ ## NAME;\
    }\
    - (instancetype)update_ ## NAME:(TYPE)VAL


@interface MCKVerification ()

@property (nonatomic, assign) BOOL hasVerificationHandlerSet;
@property (nonatomic, assign) BOOL hasTimeoutSet;
@property (nonatomic, strong) MCKVerificationResult *result;
@property (nonatomic, readonly) NSMutableArray *verifiedPrototypes;

@end

@implementation MCKVerification

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context location:(MCKLocation *)location verificationBlock:(MCKVerificationBlock)block
{
    if ((self = [super init])) {
        _mockingContext = context;
        _verificationBlock = [block copy];
        _location = location;
        _verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
        _verifiedPrototypes = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Configuration

CONFIG_BLOCK_IMPL(setVerificationHandler, id<MCKVerificationHandler>, handler)
{
    if (self.hasVerificationHandlerSet) {
        MCKAPIMisuse(@"Can only set one verification type per verification");
    }
    else if (handler == nil) {
        MCKAPIMisuse(@"You cannot set 'nil' as a verification type");
    }
    self.hasVerificationHandlerSet = YES;
    
    _verificationHandler = handler;
    return self;
}

CONFIG_BLOCK_IMPL(setTimeout, NSTimeInterval, timeout)
{
    if (self.hasTimeoutSet) {
        MCKAPIMisuse(@"Can only set one timeout per verification");
    }
    self.hasTimeoutSet = YES;
    
    _timeout = timeout;
    return self;
}


#pragma mark - Execution

- (MCKVerificationResult *)execute
{
    // The verification calls are routed via the MCKMockingContext to the
    // MCKInvocationVerifier. The verifier in turn passes it along
    // to this object which then will check the result and return
    // it from the 'result' instance variable
    
    [self.mockingContext updateContextMode:MCKContextModeVerifying];
    [self.verifiedPrototypes removeAllObjects];
    
    if (self.verificationBlock != nil) {
        self.verificationBlock();
    }
    
    [self.mockingContext updateContextMode:MCKContextModeRecording];
    
    if (self.verifiedPrototypes.count > 1) {
        MCKAPIMisuse(@"Cannot check more than one method in a match(...) call. Maybe you used the return of a stub as a method parameter?");
    }
    
    return self.result;
}

- (void)verifyPrototype:(MCKInvocationPrototype *)prototype inInvocationRecorder:(MCKInvocationRecorder *)recorder
{
    NSParameterAssert(prototype != nil);
    NSParameterAssert(recorder != nil);
    
    MCKVerificationResult *result = [self.verificationHandler verifyInvocations:recorder.recordedInvocations forPrototype:prototype];
    
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:self.timeout];
    while ([self mustProcessTimeoutForResult:result] && [self didNotYetReachDate:lastDate]) {
        [self.mockingContext updateContextMode:MCKContextModeRecording];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:lastDate];
        [self.mockingContext updateContextMode:MCKContextModeVerifying];
        result = [self.verificationHandler verifyInvocations:recorder.recordedInvocations forPrototype:prototype];
    }
    
    [self.verifiedPrototypes addObject:prototype];
    self.result = result;
}

- (BOOL)mustProcessTimeoutForResult:(MCKVerificationResult *)result
{
    if (self.timeout <= 0.0) {
        return NO;
    }
    else {
        return [self.verificationHandler mustAwaitTimeoutForResult:result];
    }
}

- (BOOL)didNotYetReachDate:(NSDate *)lastDate
{
    return ([lastDate laterDate:[NSDate date]] == lastDate);
}

@end
