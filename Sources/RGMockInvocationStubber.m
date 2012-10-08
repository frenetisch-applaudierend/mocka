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
    RGMockStubbing *stubbing = [[RGMockStubbing alloc] init];
    [stubbing addInvocation:invocation withNonObjectArgumentMatchers:matchers];
    [_stubbings addObject:stubbing];
}

- (void)addActionToCurrentStubbing:(id<RGMockStubAction>)action {
}


#pragma mark - Querying and Applying Stubbings

- (NSArray *)stubbingsMatchingInvocation:(NSInvocation *)invocation {
    return nil;
}

- (void)applyStubbingToInvocation:(NSInvocation *)invocation {
}

@end
