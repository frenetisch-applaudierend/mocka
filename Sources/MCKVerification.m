//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 26.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerification.h"
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


@end

@implementation MCKVerification

#pragma mark - Initialization

- (instancetype)initWithVerificationBlock:(MCKVerificationBlock)block location:(MCKLocation *)location
{
    if ((self = [super init])) {
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

- (MCKVerificationResult *)execute {
    return nil;
}

@end
