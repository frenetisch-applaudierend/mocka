//
//  RGMockInvocationMatcherFake.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationMatcherFake.h"


@interface _RGMockInvocationPair : NSObject

@property (nonatomic, readwrite, strong) NSInvocation *invocation;
@property (nonatomic, readwrite, strong) NSInvocation *candidate;

@end

@implementation _RGMockInvocationPair

@synthesize invocation, candidate;

+ (id)pairWithInvocation:(NSInvocation *)inv candidate:(NSInvocation *)cand {
    _RGMockInvocationPair *pair = [[self alloc] init];
    pair.invocation = inv;
    pair.candidate = cand;
    return pair;
}

- (BOOL)isEqual:(id)object {
    return ((invocation == [object invocation] && candidate == [object candidate])
            || (candidate == [object invocation] && invocation == [object candidate]));
}

@end


#pragma mark -
@interface RGMockInvocationMatcherFake () {
@private
    NSMutableSet *_invocationPairs;
}
@end

@implementation RGMockInvocationMatcherFake

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _invocationPairs = [NSMutableSet set];
    }
    return self;
}


#pragma mark - Fake Methods

- (void)fake_shouldMatchInvocation:(NSInvocation *)invocation withInvocation:(NSInvocation *)candidate {
    [_invocationPairs addObject:[_RGMockInvocationPair pairWithInvocation:invocation candidate:candidate]];
}

- (BOOL)invocation:(NSInvocation *)invocation matchesInvocation:(NSInvocation *)candidate {
    return [_invocationPairs containsObject:[_RGMockInvocationPair pairWithInvocation:invocation candidate:candidate]];
}

@end
