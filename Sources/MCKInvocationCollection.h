//
//  MCKInvocationCollection.h
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCKInvocationMatcher;


// Record invocations, query for recorded invocations and remove invocations
@interface MCKInvocationCollection : NSObject

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher;


#pragma mark - Recording invocations

- (void)addInvocation:(NSInvocation *)invocation;


#pragma mark - Querying recorded invocations

@property (nonatomic, readonly) NSArray *allInvocations;

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)argMatchers;


#pragma mark - Removing recorded invocations

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes;

@end
