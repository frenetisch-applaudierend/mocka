//
//  MCKInvocationRecorder.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKMockingContext;
@class MCKInvocationPrototype;


@interface MCKInvocationRecorder : NSObject

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context;

@property (nonatomic, readonly, weak) MCKMockingContext *mockingContext;


#pragma mark - Handling Prototypes

- (void)handleInvocationPrototype:(MCKInvocationPrototype *)prototype;


#pragma mark - Managing Invocations

@property (nonatomic, readonly) NSArray *recordedInvocations;

- (NSInvocation *)invocationAtIndex:(NSUInteger)index;

- (void)appendInvocation:(NSInvocation *)invocation;
- (void)insertInvocations:(NSArray *)invocations atIndex:(NSUInteger)index;

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes;
- (void)removeInvocationsInRange:(NSRange)range;

@end
