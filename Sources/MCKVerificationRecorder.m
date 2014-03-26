//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 25.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerificationRecorder.h"
#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKVerification.h"
#import "MCKAPIMisuse.h"


#define CONFIG_BLOCK_IMPL(NAME, TYPE, VAL)\
    @synthesize NAME = _ ## NAME;\
    - (MCKVerificationRecorder *(^)(TYPE))NAME {\
        if (_ ## NAME == nil) {\
            __weak typeof(self) weakSelf = self;\
            _ ## NAME = ^(TYPE value) {\
                return [weakSelf update_ ## NAME:value];\
            };\
        }\
        return _ ## NAME;\
    }\
    - (instancetype)update_ ## NAME:(TYPE)VAL


@interface MCKVerificationRecorder ()

@property (nonatomic, readwrite) MCKVerificationBlock verificationBlock;
@property (nonatomic, readwrite) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, readwrite) NSNumber *timeout;

@end

@implementation MCKVerificationRecorder

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context location:(MCKLocation *)location
{
    if ((self = [super init])) {
        _mockingContext = context;
        _location = location;
    }
    return self;
}

- (void)dealloc
{
    MCKVerification *verification = [[MCKVerification alloc] initWithVerificationBlock:_verificationBlock
                                                                   verificationHandler:_verificationHandler
                                                                               timeout:[_timeout doubleValue]
                                                                              location:_location];
    [_mockingContext.invocationVerifier processVerification:verification];
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
