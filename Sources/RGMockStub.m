//
//  RGMockStubbing.m
//  rgmock
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockStub.h"
#import "RGMockStubAction.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockStub {
    NSMutableArray          *_invocationPrototypes;
    NSMutableArray          *_actions;
    RGMockInvocationMatcher *_invocationMatcher;
}


#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _invocationPrototypes = [NSMutableArray array];
        _actions = [NSMutableArray array];
        _invocationMatcher = [[RGMockInvocationMatcher alloc] init];
    }
    return self;
}


#pragma mark - Configuration

- (void)addInvocation:(NSInvocation *)invocation withNonObjectArgumentMatchers:(NSArray *)argumentMatchers {
    [_invocationPrototypes addObject:[[RGMockStubInvocationPrototpye alloc] initWithInvocation:invocation nonObjectArgumentMatchers:argumentMatchers]];
}

- (void)addAction:(id<RGMockStubAction>)action {
    [_actions addObject:action];
}

- (NSArray *)invocationPrototypes {
    return [_invocationPrototypes copy];
}

- (NSArray *)actions {
    return [_actions copy];
}


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)candidate {
    for (RGMockStubInvocationPrototpye *prototype in _invocationPrototypes) {
        if ([_invocationMatcher invocation:candidate matchesPrototype:prototype.invocation withNonObjectArgumentMatchers:prototype.nonObjectArgumentMatchers]) {
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


@implementation RGMockStubInvocationPrototpye

- (id)initWithInvocation:(NSInvocation *)invocation nonObjectArgumentMatchers:(NSArray *)argumentMatchers {
    if ((self = [super init])) {
        _invocation = invocation;
        _nonObjectArgumentMatchers = [argumentMatchers copy];
    }
    return self;
}

@end
