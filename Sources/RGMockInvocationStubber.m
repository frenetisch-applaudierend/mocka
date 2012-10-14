//
//  RGMockInvocationStubber.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationStubber.h"
#import "RGMockStub.h"


@implementation RGMockInvocationStubber {
    NSMutableArray *_recordedStubs;
    BOOL            _groupRecording;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _recordedStubs = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Creating and Updating Stubbings

- (void)recordStubInvocation:(NSInvocation *)invocation withNonObjectArgumentMatchers:(NSArray *)matchers {
    NSParameterAssert(invocation != nil);
    
    if (![self isRecordingInvocationGroup]) {
        [self pushNewStubForRecordingInvocationGroup];
    }
    [[self activeStub] addInvocation:invocation withNonObjectArgumentMatchers:matchers];
}

- (void)addActionToLastStub:(id<RGMockStubAction>)action {
    NSParameterAssert(action != nil);
    
    if ([self isRecordingInvocationGroup]) {
        [self endRecordingInvocationGroup];
    }
    [[self activeStub] addAction:action];
}


#pragma mark - Querying and Applying Stubbings

- (NSArray *)recordedStubs {
    return [_recordedStubs copy];
}

- (void)applyActionsToStubsForInvocation:(NSInvocation *)invocation {
    NSParameterAssert(invocation != nil);
}


#pragma mark - Managing Invocation Group Recording

- (BOOL)isRecordingInvocationGroup {
    return _groupRecording;
}

- (void)pushNewStubForRecordingInvocationGroup {
    _groupRecording = YES;
    [_recordedStubs addObject:[[RGMockStub alloc] init]];
}

- (void)endRecordingInvocationGroup {
    _groupRecording = NO;
}

- (RGMockStub *)activeStub {
    return [_recordedStubs lastObject];
}


@end
