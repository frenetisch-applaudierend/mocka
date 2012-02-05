//
//  RGMockObject.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockRecorder.h"
#import "RGMockInvocationMatcher.h"


@interface RGMockRecorder () {
@private
    RGMockInvocationMatcher *_invocationMatcher;
    NSMutableArray          *_recordedInvocations;
}
@end


@implementation RGMockRecorder

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(RGMockInvocationMatcher *)matcher {
    if ((self = [super init])) {
        _invocationMatcher = matcher;
        _recordedInvocations = [NSMutableArray array];
    }
    return self;
}

- (id)init {
    return [self initWithInvocationMatcher:[[RGMockInvocationMatcher alloc] init]];
}


#pragma mark - Invocation Recording

- (void)mock_recordInvocation:(NSInvocation *)invocation {
    [_recordedInvocations addObject:invocation];
}

- (NSArray *)mock_recordedInvocations {
    return [_recordedInvocations copy];
}


#pragma mark - Invocation Matching

- (NSArray *)mock_recordedInvocationsMatchingInvocation:(NSInvocation *)invocation {
    NSMutableArray *matchingInvocations = [NSMutableArray array];
    for (NSInvocation *candidate in _recordedInvocations) {
        if ([_invocationMatcher invocation:invocation matchesInvocation:candidate]) {
            [matchingInvocations addObject:candidate];
        }
    }
    return matchingInvocations;
}


#pragma mark - Handling Unknown Methods

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self mock_recordInvocation:invocation];
}

@end
