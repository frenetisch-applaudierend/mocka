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
#import "MCKVerification.h"


@implementation MCKVerificationRecorder

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
{
    if ((self = [super init])) {
        _mockingContext = context;
    }
    return self;
}


#pragma mark - Recording Verifications

- (MCKVerification *)recordVerification
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"You should not call the getter for this property" userInfo:nil];
}

- (void)setRecordVerification:(MCKVerification *)verification
{
    [self.mockingContext.invocationVerifier processVerification:verification];
}

@end
