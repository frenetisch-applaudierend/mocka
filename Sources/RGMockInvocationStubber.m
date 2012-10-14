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
    NSMutableArray *_stubs;
    BOOL            _groupRecording;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _stubs = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Creating and Updating Stubbings

- (void)recordStubInvocation:(NSInvocation *)invocation withNonObjectArgumentMatchers:(NSArray *)matchers {
    if (![self isRecordingInvocationGroup]) {
        [self startRecordingInvocationGroup];
        [self pushNewActiveStub];
    }
    [[self activeStub] addInvocation:invocation withNonObjectArgumentMatchers:matchers];
}

- (void)addActionToLastStub:(id<RGMockStubAction>)action {
    [self endRecordingInvocationGroup];
}


#pragma mark - Querying and Applying Stubbings

- (NSArray *)stubbingsMatchingInvocation:(NSInvocation *)invocation {
    return nil;
}

- (void)applyStubbingToInvocation:(NSInvocation *)invocation {
}


#pragma mark - Managing Invocation Group Recording

- (BOOL)isRecordingInvocationGroup {
    return _groupRecording;
}

- (void)startRecordingInvocationGroup {
    _groupRecording = YES;
}

- (void)endRecordingInvocationGroup {
    _groupRecording = NO;
}

- (void)pushNewActiveStub {
    [_stubs addObject:[[RGMockStub alloc] init]];
}

- (RGMockStub *)activeStub {
    return [_stubs lastObject];
}


@end
