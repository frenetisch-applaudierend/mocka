//
//  RGMockObjectFake.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockRecorderFake.h"

@interface RGMockRecorderFake () {
@private
    RGMockRecorder *_realRecorder;
    NSMutableSet   *_invocationsThatShouldMatch;
    NSMutableSet   *_invocationsThatShouldNotMatch;
    NSMutableSet   *_invocationsTriedToMatch;
}
@end


@implementation RGMockRecorderFake

#pragma mark - Initialization

+ (id)fakeWithRealRecorder:(RGMockRecorder *)recorder {
    return [[self alloc] initWithRealRecorder:recorder];
}

- (id)initWithRealRecorder:(RGMockRecorder *)recorder {
    if ((self = [super init])) {
        _realRecorder = recorder;
        _invocationsThatShouldMatch = [NSMutableSet set];
        _invocationsThatShouldNotMatch = [NSMutableSet set];
        _invocationsTriedToMatch = [NSMutableSet set];
    }
    return self;
}


#pragma mark - Fake Invocation Matching

- (BOOL)fake_set:(NSSet *)set containsInvocation:(NSInvocation *)invocation {
    __block BOOL retval = NO;
    [set enumerateObjectsUsingBlock:^(NSInvocation *candidate, BOOL *stop) {
        if (invocation.target == candidate.target && invocation.selector == candidate.selector) {
            *stop = retval = YES;
        }
    }];
    return retval;
}

- (void)fake_shouldMatchInvocation:(NSInvocation *)invocation {
    [_invocationsThatShouldMatch addObject:invocation];
    [_invocationsThatShouldNotMatch removeObject:invocation];
}

- (void)fake_shouldNotMatchInvocation:(NSInvocation *)invocation {
    [_invocationsThatShouldNotMatch addObject:invocation];
    [_invocationsThatShouldMatch removeObject:invocation];
}

- (BOOL)fake_didTryMatchingInvocation:(NSInvocation *)invocation {
    return [self fake_set:_invocationsTriedToMatch containsInvocation:invocation];
}

- (NSArray *)mock_recordedInvocationsMatchingInvocation:(NSInvocation *)invocation {
    [_invocationsTriedToMatch addObject:invocation];
    
    if ([self fake_set:_invocationsThatShouldMatch containsInvocation:invocation]) {
        return [NSArray arrayWithObject:invocation];
    } else if ([self fake_set:_invocationsThatShouldNotMatch containsInvocation:invocation]) {
        return [NSArray array];
    } else {
        return [_realRecorder mock_recordedInvocationsMatchingInvocation:invocation];
    }
}


#pragma mark - Relaying to the Real Recorder

- (BOOL)respondsToSelector:(SEL)selector {
    return ([super respondsToSelector:selector] || [_realRecorder respondsToSelector:selector]);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil) {
        signature = [_realRecorder methodSignatureForSelector:selector];
    }
    return signature;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _realRecorder;
}

@end
