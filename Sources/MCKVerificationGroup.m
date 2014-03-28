//
//  MCKVerificationGroup.m
//  mocka
//
//  Created by Markus Gasser on 28.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerificationGroup.h"
#import "MCKMockingContext.h"


@implementation MCKVerificationGroup

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
                             collector:(id<MCKVerificationResultCollector>)collector
                verificationGroupBlock:(MCKVerificationGroupBlock)block
{
    if ((self = [super init])) {
        _mockingContext = context;
        _resultCollector = collector;
        _verificationGroupBlock = [block copy];
    }
    return self;
}


#pragma mark - Executing

- (MCKVerificationResult *)execute
{
    // The verification calls are routed via the MCKMockingContext to the
    // MCKInvocationVerifier. The verifier in turn passes it along
    // to this object which then will check the result using the collector
    
    [self.mockingContext updateContextMode:MCKContextModeVerifying];
    if (self.verificationGroupBlock != nil) {
        self.verificationGroupBlock();
    }
    [self.mockingContext updateContextMode:MCKContextModeRecording];
    
    return nil;
}


@end
