//
//  MCKInvocationCollection.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationCollection.h"
#import "MCKInvocationMatcher.h"
#import "MCKArgumentMatcherCollection.h"


@interface MCKInvocationCollection () {
@protected
    NSMutableArray *_storedInvocations;
    MCKInvocationMatcher *_invocationMatcher;
}
@end


@implementation MCKInvocationCollection

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher invocations:(NSArray *)invocations {
    if ((self = [super init])) {
        _storedInvocations = (invocations != nil ? [invocations mutableCopy] : [NSMutableArray array]);
        _invocationMatcher = matcher;
    }
    return self;
}

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher {
    return [self initWithInvocationMatcher:matcher invocations:nil];
}

- (id)init {
    return [self initWithInvocationMatcher:[MCKInvocationMatcher matcher] invocations:nil];
}


#pragma mark - Querying for invocations

- (NSArray *)allInvocations {
    return [_storedInvocations copy];
}

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withArgumentMatchers:(MCKArgumentMatcherCollection *)argMatchers {
    NSIndexSet *matchingIndexes = [_storedInvocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
        return [_invocationMatcher invocation:candidate matchesPrototype:prototype withPrimitiveArgumentMatchers:argMatchers.primitiveArgumentMatchers];
    }];
    return matchingIndexes;
}


#pragma mark - Deriving New Collections

- (MCKInvocationCollection *)subcollectionFromIndex:(NSUInteger)skip {
    NSArray *newInvocations = [_storedInvocations subarrayWithRange:NSMakeRange(skip, [_storedInvocations count] - skip)];
    return [[MCKInvocationCollection alloc] initWithInvocationMatcher:_invocationMatcher invocations:newInvocations];
}

@end


@implementation MCKMutableInvocationCollection

#pragma mark - Adding and Removing Invocations

- (void)addInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    [_storedInvocations addObject:invocation];
}

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes {
    [_storedInvocations removeObjectsAtIndexes:indexes];
}

@end
