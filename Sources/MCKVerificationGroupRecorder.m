//
//  MCKVerificationGroupRecorder.m
//  mocka
//
//  Created by Markus Gasser on 29.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKVerificationGroupRecorder.h"
#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"
#import "MCKVerificationGroup.h"


@implementation MCKVerificationGroupRecorder

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
                              location:(MCKLocation *)location
                       resultCollector:(id<MCKVerificationResultCollector>)collector
{
    if ((self = [super init])) {
        _mockingContext = context;
        _location = location;
        _resultCollector = collector;
    }
    return self;
}


#pragma mark - Recording

- (MCKVerificationGroupBlock)recordGroupWithBlock
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"You should not call the getter for this property" userInfo:nil];
}

- (void)setRecordGroupWithBlock:(MCKVerificationGroupBlock)block
{
    MCKVerificationGroup *verificationGroup = [[MCKVerificationGroup alloc] initWithMockingContext:self.mockingContext
                                                                                          location:self.location
                                                                                         collector:self.resultCollector
                                                                            verificationGroupBlock:block];
    [self.mockingContext.invocationVerifier processVerificationGroup:verificationGroup];
}

@end
