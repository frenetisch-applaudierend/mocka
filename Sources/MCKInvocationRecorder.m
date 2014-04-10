//
//  MCKInvocationRecorder.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKInvocationRecorder.h"
#import "MCKMockingContext.h"
#import "MCKInvocationStubber.h"
#import "MCKInvocationPrototype.h"


@interface MCKInvocationRecorder ()

@property (nonatomic, readonly) NSMutableArray *mutableInvocations;

@end

@implementation MCKInvocationRecorder

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context {
    if ((self = [super init])) {
        _mockingContext = context;
        _mutableInvocations = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Managing Invocations

- (NSArray *)recordedInvocations {
    @synchronized (self.mutableInvocations) {
        return [self.mutableInvocations copy];
    }
}

- (NSInvocation *)invocationAtIndex:(NSUInteger)index {
    @synchronized (self.mutableInvocations) {
        return [self.mutableInvocations objectAtIndex:index];
    }
}

- (void)recordInvocationFromPrototype:(MCKInvocationPrototype *)prototype {
    [self appendInvocation:prototype.invocation];
    [self.mockingContext.invocationStubber applyStubsForInvocation:prototype.invocation];
}

- (void)appendInvocation:(NSInvocation *)invocation {
    @synchronized (self.mutableInvocations) {
        [self.mutableInvocations addObject:invocation];
    }
}

- (void)insertInvocations:(NSArray *)invocations atIndex:(NSUInteger)index {
    @synchronized (self.mutableInvocations) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [invocations count])];
        [self.mutableInvocations insertObjects:invocations atIndexes:indexes];
    }
}

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes {
    @synchronized (self.mutableInvocations) {
        [self.mutableInvocations removeObjectsAtIndexes:indexes];
    }
}

- (void)removeInvocationsInRange:(NSRange)range {
    @synchronized (self.mutableInvocations) {
        [self.mutableInvocations removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    }
}

@end
