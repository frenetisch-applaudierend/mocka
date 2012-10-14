//
//  RGMockInvocationStubber.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationStubber.h"
#import "RGMockStub.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockInvocationStubber {
    NSMutableArray *_recordedStubs;
    BOOL _groupRecording;
    RGMockInvocationMatcher *_invocationMatcher;
}

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(RGMockInvocationMatcher *)invocationMatcher {
    if ((self = [super init])) {
        _recordedStubs = [NSMutableArray array];
        _invocationMatcher = invocationMatcher;
    }
    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use -initWithInvocationMatcher:" userInfo:nil];
}


#pragma mark - Creating and Updating Stubbings

- (void)recordStubInvocation:(NSInvocation *)invocation withPrimitiveArgumentMatchers:(NSArray *)matchers {
    NSParameterAssert(invocation != nil);
    
    if (![self isRecordingInvocationGroup]) {
        [self pushNewStubForRecordingInvocationGroup];
    }
    [[self activeStub] addInvocation:invocation withPrimitiveArgumentMatchers:matchers];
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

- (BOOL)hasStubsRecordedForInvocation:(NSInvocation *)invocation {
    NSParameterAssert(invocation != nil);
    
    NSUInteger index = [_recordedStubs indexOfObjectPassingTest:^BOOL(RGMockStub *stub, NSUInteger idx, BOOL *stop) {
        return [stub matchesForInvocation:invocation];
    }];
    return (index != NSNotFound);
}

- (void)applyStubsForInvocation:(NSInvocation *)invocation {
    NSParameterAssert(invocation != nil);
    
    for (RGMockStub *stub in _recordedStubs) {
        if ([stub matchesForInvocation:invocation]) {
            [stub applyToInvocation:invocation];
        }
    }
}


#pragma mark - Managing Invocation Group Recording

- (BOOL)isRecordingInvocationGroup {
    return _groupRecording;
}

- (void)pushNewStubForRecordingInvocationGroup {
    _groupRecording = YES;
    [_recordedStubs addObject:[[RGMockStub alloc] initWithInvocationMatcher:_invocationMatcher]];
}

- (void)endRecordingInvocationGroup {
    _groupRecording = NO;
}

- (RGMockStub *)activeStub {
    return [_recordedStubs lastObject];
}

@end
