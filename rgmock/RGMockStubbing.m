//
//  RGMockStubbing.m
//  rgmock
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockStubbing.h"
#import "RGMockStubAction.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockStubbing {
    NSMutableArray *_invocations;
    NSMutableArray *_actions;
}


#pragma mark - Initialization and Configuration

- (id)initWithInvocation:(NSInvocation *)invocation {
    if ((self = [super init])) {
        _invocations = [NSMutableArray arrayWithObject:invocation];
        _actions = [NSMutableArray array];
    }
    return self;
}

- (void)addInvocation:(NSInvocation *)invocation {
    [_invocations addObject:invocation];
}

- (void)addAction:(id<RGMockStubAction>)action {
    [_actions addObject:action];
}


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)invocation {
    for (NSInvocation *prototype in _invocations) {
        if ([[RGMockInvocationMatcher defaultMatcher] invocation:invocation matchesPrototype:prototype]) {
            return YES;
        }
    }
    return NO;
}

- (void)applyToInvocation:(NSInvocation *)invocation {
    for (id<RGMockStubAction> action in _actions) {
        [action performWithInvocation:invocation];
    }
}

@end
