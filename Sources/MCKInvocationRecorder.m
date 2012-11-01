//
//  MCKInvocationRecorder.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationRecorder.h"
#import "MCKInvocationMatcher.h"


@implementation MCKInvocationRecorder {
    NSMutableArray *_recordedInvocations;
    MCKInvocationMatcher *_invocationMatcher;
}

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher {
    if ((self = [super init])) {
        _recordedInvocations = [NSMutableArray array];
        _invocationMatcher = matcher;
    }
    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use -initWithInvocationMatcher:" userInfo:nil];
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

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)argMatchers {
    NSIndexSet *matchingIndexes = [_recordedInvocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
        return [_invocationMatcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argMatchers];
    }];
    return matchingIndexes;
}


#pragma mark - Removing recorded invocations

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes {
    [_recordedInvocations removeObjectsAtIndexes:indexes];
}

@end
