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


// Record invocations, query for recorded invocations and remove invocations
@interface MCKInvocationCollection : NSObject

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)matcher;


#pragma mark - Querying for invocations

@property (nonatomic, readonly) NSArray *allInvocations;

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withArgumentMatchers:(MCKArgumentMatcherCollection *)argMatchers;

@end


@interface MCKMutableInvocationCollection : MCKInvocationCollection

#pragma mark - Adding and Removing Invocations

- (void)addInvocation:(NSInvocation *)invocation;
- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes;

@end
