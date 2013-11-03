//
//  MCKInvocationRecorder.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKInvocationRecorder.h"


@interface MCKInvocationRecorder ()

//@property (nonatomic, readonly) NSMutableArray *mutableInvocations;

@end

@implementation MCKInvocationRecorder

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _mutableInvocations = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Managing Invocations

- (NSArray *)recordedInvocations {
    return [self.mutableInvocations copy];
}

- (void)recordInvocation:(NSInvocation *)invocation {
    NSParameterAssert(invocation != nil);
    
    [self.mutableInvocations addObject:invocation];
    [self.delegate invocationRecorder:self didRecordInvocation:invocation];
}

@end
