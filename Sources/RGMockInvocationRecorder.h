//
//  RGMockInvocationRecorder.h
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMockInvocationMatcher;


// Record invocations, query for recorded invocations and remove invocations
@interface RGMockInvocationRecorder : NSObject

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(RGMockInvocationMatcher *)matcher;
- (id)init;


#pragma mark - Recording invocations

- (void)recordInvocation:(NSInvocation *)invocation;


#pragma mark - Querying recorded invocations

@property (nonatomic, readonly) NSArray *recordedInvocations;

- (NSIndexSet *)invocationsMatchingPrototype:(NSInvocation *)prototype withNonObjectArgumentMatchers:(NSArray *)argMatchers;


#pragma mark - Removing recorded invocations

- (void)removeInvocationsAtIndexes:(NSIndexSet *)indexes;

@end
