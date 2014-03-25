//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 25.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerification.h"
#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"
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

@property (nonatomic, readwrite) MCKVerificationBlock verificationBlock;
@property (nonatomic, readwrite) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, readwrite) NSNumber *timeout;

@end

@implementation MCKVerification

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
{
    if ((self = [super init])) {
        _mockingContext = context;
    }
    return self;
}

- (void)dealloc
{
    [self.mockingContext.invocationVerifier executeVerificationWithBlock:_verificationBlock
                                                                 handler:_verificationHandler
                                                                 timeout:[_timeout doubleValue]];
}


#pragma mark - Calculated Properties

- (id<MCKVerificationHandler>)verificationHandler
{
    return (_verificationHandler ?: [MCKDefaultVerificationHandler defaultHandler]);
}


#pragma mark - Configuration


CONFIG_BLOCK_IMPL(setVerificationBlock, MCKVerificationBlock, block)
{
    if (_verificationBlock != nil) {
        MCKAPIMisuse(@"Can only set one verification block per verification");
    }
    else if (block == nil) {
        MCKAPIMisuse(@"You cannot set 'nil' as a verification block");
    }
    
    self.verificationBlock = block;
    return self;
}

CONFIG_BLOCK_IMPL(setVerificationHandler, id<MCKVerificationHandler>, handler)
{
    if (_verificationHandler != nil) {
        MCKAPIMisuse(@"Can only set one verification type per verification");
    }
    else if (handler == nil) {
        MCKAPIMisuse(@"You cannot set 'nil' as a verification type");
    }
    
    self.verificationHandler = handler;
    return self;
}

CONFIG_BLOCK_IMPL(setTimeout, NSNumber*, timeout)
{
    if (_timeout != nil) {
        MCKAPIMisuse(@"Can only set one timeout per verification");
    }
    
    self.timeout = timeout;
    return self;
}

@end
