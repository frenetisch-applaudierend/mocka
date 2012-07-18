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
    NSInvocation   *_invocation;
    NSMutableArray *_actions;
}


#pragma mark - Initialization and Configuration

- (id)initWithInvocation:(NSInvocation *)invocation {
    if ((self = [super init])) {
        _invocation = invocation;
        _actions = [NSMutableArray array];
    }
    return self;
}

- (void)addAction:(id<RGMockStubAction>)action {
    [_actions addObject:action];
}


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)invocation {
    return [[RGMockInvocationMatcher defaultMatcher] invocation:invocation matchesPrototype:_invocation];
}

- (void)applyToInvocation:(NSInvocation *)invocation {
    for (id<RGMockStubAction> action in _actions) {
        [action performWithInvocation:invocation];
    }
}

@end
