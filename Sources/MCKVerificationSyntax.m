//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 7.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKVerificationSyntax.h"
#import "MCKMockingContext.h"


MCKVerificationRecorder* _MCKVerificationRecorder(void)
{
    return [[MCKVerificationRecorder alloc] initWithMockingContext:[MCKMockingContext currentContext]];
}

MCKVerification* _MCKVerification(MCKLocation *location, MCKVerificationBlock block)
{
    return [[MCKVerification alloc] initWithMockingContext:[MCKMockingContext currentContext] location:location verificationBlock:block];
}

MCKVerificationGroupRecorder* _MCKVerificationGroupRecorder(MCKLocation *location, id<MCKVerificationResultCollector> collector)
{
    return [[MCKVerificationGroupRecorder alloc] initWithMockingContext:[MCKMockingContext currentContext] location:location resultCollector:collector];
}
