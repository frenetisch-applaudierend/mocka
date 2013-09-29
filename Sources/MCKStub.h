//
//  MCKStub.h
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKInvocationMatcher;
@class MCKInvocationPrototype;
@protocol MCKStubAction;


@interface MCKStub : NSObject

#pragma mark - Initialization

- (instancetype)initWithInvocationMatcher:(MCKInvocationMatcher *)invocationMatcher;


#pragma mark - Configuration

@property (nonatomic, readonly, copy) NSArray *invocationPrototypes;
@property (nonatomic, readonly, copy) NSArray *actions;

- (void)addInvocationPrototype:(MCKInvocationPrototype *)prototype;
- (void)addAction:(id<MCKStubAction>)action;


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)invocation;

- (void)applyToInvocation:(NSInvocation *)invocation;

@end
