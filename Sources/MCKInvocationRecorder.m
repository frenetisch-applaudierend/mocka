//
//  MCKInvocationRecorder.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKInvocationRecorder.h"


@interface MCKInvocationRecorder ()

@property (nonatomic, readonly) NSMutableArray *mutableInvocations;

@end

@implementation MCKInvocationRecorder

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _mutableInvocations = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Managing Invocations

- (NSArray *)recordedInvocations {
    return [self.mutableInvocations copy];
}

- (NSInvocation *)invocationAtIndex:(NSUInteger)index {
    return [self.mutableInvocations objectAtIndex:index];
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [self appendInvocation:invocation];
    [self.delegate invocationRecorder:self didRecordInvocation:invocation];
}

- (void)appendInvocation:(NSInvocation *)invocation {
    [self.mutableInvocations addObject:invocation];
}

- (void)insertInvocations:(NSArray *)invocations atIndex:(NSUInteger)index {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [invocations count])];
    [self.mutableInvocations insertObjects:invocations atIndexes:indexes];
}

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes {
    [self.mutableInvocations removeObjectsAtIndexes:indexes];
}

- (void)removeInvocationsInRange:(NSRange)range {
    [self.mutableInvocations removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

@end
