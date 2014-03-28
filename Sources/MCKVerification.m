//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 26.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerification.h"
#import "MCKMockingContext.h"
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
    if (self.verificationBlock != nil) {
        self.verificationBlock();
    }
    
    [self.mockingContext updateContextMode:MCKContextModeRecording];
    return self.result;
}

//- (MCKVerificationResult *)resultForInvocationPrototype:(MCKInvocationPrototype *)prototype
//{
//    MCKVerificationResult *result = [self currentResultForPrototype:prototype];
//    
//    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:self.timeout];
//    while ([self mustProcessTimeoutForResult:result] && [self didNotYetReachDate:lastDate]) {
//        [self.mockingContext updateContextMode:MCKContextModeRecording];
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:lastDate];
//        [self.mockingContext updateContextMode:MCKContextModeVerifying];
//        result = [self currentResultForPrototype:prototype];
//    }
//    return result;
//}
//
//- (MCKVerificationResult *)currentResultForPrototype:(MCKInvocationPrototype *)prototype
//{
//    NSArray *recordedInvocations = self.mockingContext.invocationRecorder.recordedInvocations;
//    return [self.verificationHandler verifyInvocations:recordedInvocations forPrototype:prototype];
//}
//
//- (BOOL)mustProcessTimeoutForResult:(MCKVerificationResult *)result
//{
//    if (self.timeout <= 0.0) {
//        return NO;
//    }
//    else {
//        return [self.verificationHandler mustAwaitTimeoutForResult:result];
//    }
//}
//
//- (BOOL)didNotYetReachDate:(NSDate *)lastDate
//{
//    return ([lastDate laterDate:[NSDate date]] == lastDate);
//}

@end
