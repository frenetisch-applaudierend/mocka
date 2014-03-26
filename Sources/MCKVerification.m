//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 26.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerification.h"


@implementation MCKVerification

#pragma mark - Initialization

- (instancetype)initWithVerificationBlock:(void(^)(void))block
                      verificationHandler:(id<MCKVerificationHandler>)handler
                                  timeout:(NSTimeInterval)timeout
                                 location:(MCKLocation *)location
{
    if ((self = [super init])) {
        _verificationBlock = [block copy];
        _verificationHandler = handler;
        _timeout = timeout;
        _location = location;
    }
    return self;
}

@end
