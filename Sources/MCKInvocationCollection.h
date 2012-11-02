//
//  MCKInvocationCollection.h
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCKInvocationMatcher;
@class MCKArgumentMatcherCollection;


@interface MCKInvocationCollection : NSObject

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher invocations:(NSArray *)invocations;
- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher;
- (id)init;


#pragma mark - Querying for invocations

@property (nonatomic, readonly) NSArray *allInvocations;

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withArgumentMatchers:(MCKArgumentMatcherCollection *)argMatchers;


#pragma mark - Deriving New Collections

- (MCKInvocationCollection *)subcollectionFromIndex:(NSUInteger)skip;

@end


@interface MCKMutableInvocationCollection : MCKInvocationCollection

#pragma mark - Adding and Removing Invocations

- (void)addInvocation:(NSInvocation *)invocation;
- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes;

@end
