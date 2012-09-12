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


@interface RGMockStubbingInvocationPrototpye : NSObject

@property (nonatomic, readonly) NSInvocation *invocation;
@property (nonatomic, readonly) NSArray      *argumentMatchers;

- (id)initWithInvocation:(NSInvocation *)invocation argumentMatchers:(NSArray *)argumentMatchers;

@end

@implementation RGMockStubbingInvocationPrototpye

- (id)initWithInvocation:(NSInvocation *)invocation argumentMatchers:(NSArray *)argumentMatchers {
    if ((self = [super init])) {
        _invocation = invocation;
        _argumentMatchers = [argumentMatchers copy];
    }
    return self;
}

@end


#pragma mark -
@implementation RGMockStubbing {
    NSMutableArray *_invocations;
    NSMutableArray *_actions;
}


#pragma mark - Initialization and Configuration

- (id)init {
    if ((self = [super init])) {
        _invocations = [NSMutableArray array];
        _actions = [NSMutableArray array];
    }
    return self;
}

- (void)addInvocation:(NSInvocation *)invocation withNonObjectArgumentMatchers:(NSArray *)argumentMatchers {
    [_invocations addObject:[[RGMockStubbingInvocationPrototpye alloc] initWithInvocation:invocation argumentMatchers:argumentMatchers]];
}

- (void)addAction:(id<RGMockStubAction>)action {
    [_actions addObject:action];
}


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)candidate {
    for (RGMockStubbingInvocationPrototpye *prototype in _invocations) {
        if ([[RGMockInvocationMatcher defaultMatcher] invocation:candidate matchesPrototype:prototype.invocation withNonObjectArgumentMatchers:prototype.argumentMatchers]) {
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
