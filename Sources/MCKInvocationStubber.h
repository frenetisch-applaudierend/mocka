//
//  MCKInvocationStubber.h
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCKStub;
@class MCKInvocationMatcher;
@protocol MCKStubAction;


@interface MCKInvocationStubber : NSObject

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)invocationMatcher;


#pragma mark - Creating and Updating Stubs

- (void)recordStubInvocation:(NSInvocation *)invocation withPrimitiveArgumentMatchers:(NSArray *)matchers;
- (void)addActionToLastStub:(id<MCKStubAction>)action;


#pragma mark - Applying Stub Actions

@property (nonatomic, readonly) NSArray *recordedStubs;

- (BOOL)hasStubsRecordedForInvocation:(NSInvocation *)invocation;
- (void)applyStubsForInvocation:(NSInvocation *)invocation;

@end
