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


MCKVerificationRecorder* _mck_verificationRecorder(MCKMockingContext *context, MCKLocation *location)
{
    return [[MCKVerificationRecorder alloc] initWithMockingContext:context location:location];
}


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

@end
