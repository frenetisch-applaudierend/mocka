//
//  RGMockInvocationRecorder.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationRecorder.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockInvocationRecorder {
    NSMutableArray          *_recordedInvocations;
    RGMockInvocationMatcher *_invocationMatcher;
}

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(RGMockInvocationMatcher *)matcher {
    if ((self = [super init])) {
        _recordedInvocations = [NSMutableArray array];
        _invocationMatcher = matcher;
    }
    return self;
}

- (id)init {
    return [self initWithInvocationMatcher:[[RGMockInvocationMatcher alloc] init]];
}


#pragma mark - Recording invocations

- (void)recordInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    [_recordedInvocations addObject:invocation];
}


#pragma mark - Querying for recorded invocations

- (NSArray *)recordedInvocations {
    return [_recordedInvocations copy];
}

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withNonObjectArgumentMatchers:(NSArray *)argMatchers {
    NSIndexSet *matchingIndexes = [_recordedInvocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
        return [_invocationMatcher invocation:candidate matchesPrototype:prototype withNonObjectArgumentMatchers:argMatchers];
    }];
    return matchingIndexes;
}


#pragma mark - Removing recorded invocations

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes {
    [_recordedInvocations removeObjectsAtIndexes:indexes];
}

@end