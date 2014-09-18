//
//  MCKInvocationStubber.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationStubber.h"
#import "MCKStub.h"
#import "MCKInvocationPrototype.h"


@interface MCKInvocationStubber ()

@property (nonatomic, readonly) NSMutableArray *stubs;
@property (nonatomic, assign, getter = isRecordingInvocationGroup) BOOL recordingInvocationGroup;
@property (nonatomic, readonly) MCKStub *activeStub;

@end

@implementation MCKInvocationStubber

#pragma mark - Initialization

- (instancetype)init
{
    if ((self = [super init])) {
        _stubs = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Creating and Updating Stubbings

- (void)recordStubPrototype:(MCKInvocationPrototype *)prototype
{
    if (![self isRecordingInvocationGroup]) {
        [self pushNewStubForRecordingInvocationGroup];
    }
    [self.activeStub addInvocationPrototype:prototype];
}

- (void)finishRecordingStubGroup
{
    NSAssert([self isRecordingInvocationGroup], @"Finish called while not recording");
    
    [self endRecordingInvocationGroup];
}


#pragma mark - Querying and Applying Stubbings

- (NSArray *)recordedStubs
{
    return [self.stubs copy];
}

- (BOOL)hasStubsRecordedForInvocation:(NSInvocation *)invocation
{
    NSParameterAssert(invocation != nil);
    
    NSUInteger index = [self.stubs indexOfObjectPassingTest:^BOOL(MCKStub *stub, NSUInteger idx, BOOL *stop) {
        return [stub matchesForInvocation:invocation];
    }];
    return (index != NSNotFound);
}

- (void)applyStubsForInvocation:(NSInvocation *)invocation
{
    NSParameterAssert(invocation != nil);
    
    for (MCKStub *stub in self.stubs) {
        if ([stub matchesForInvocation:invocation]) {
            [stub applyToInvocation:invocation];
        }
    }
}


#pragma mark - Managing Invocation Group Recording

- (void)pushNewStubForRecordingInvocationGroup
{
    self.recordingInvocationGroup = YES;
    [self.stubs addObject:[[MCKStub alloc] init]];
}

- (void)endRecordingInvocationGroup
{
    self.recordingInvocationGroup = NO;
}

- (MCKStub *)activeStub
{
    return [self.stubs lastObject];
}

@end
