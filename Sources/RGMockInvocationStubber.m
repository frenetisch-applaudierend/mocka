//
//  RGMockInvocationStubber.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationStubber.h"
#import "RGMockStubbing.h"


@implementation RGMockInvocationStubber {
    NSMutableArray *_stubbings;
    RGMockStubbing *_currentStubbing;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _stubbings = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Creating and Updating Stubbings

- (void)createStubbingForInvocation:(NSInvocation *)invocation nonObjectArgumentMatchers:(NSArray *)matchers {
    if (_currentStubbing == nil) {
        _currentStubbing = [[RGMockStubbing alloc] init];
        [_stubbings addObject:_currentStubbing];
    }
    [_currentStubbing addInvocation:invocation withNonObjectArgumentMatchers:matchers];
}

- (void)addActionToCurrentStubbing:(id<RGMockStubAction>)action {
    _currentStubbing = nil; // Once the user adds an action, mark the end of multiple invocations per stubbing
}


#pragma mark - Querying and Applying Stubbings

- (NSArray *)stubbingsMatchingInvocation:(NSInvocation *)invocation {
    return nil;
}

- (void)applyStubbingToInvocation:(NSInvocation *)invocation {
}

@end
