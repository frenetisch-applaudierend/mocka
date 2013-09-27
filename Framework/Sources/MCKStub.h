//
//  MCKStub.h
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKInvocationMatcher;
@protocol MCKStubAction;


@interface MCKStub : NSObject

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)invocationMatcher;


#pragma mark - Configuration

@property (nonatomic, readonly, copy) NSArray *invocationPrototypes;
@property (nonatomic, readonly, copy) NSArray *actions;

- (void)addInvocation:(NSInvocation *)invocation withPrimitiveArgumentMatchers:(NSArray *)argumentMatchers;
- (void)addAction:(id<MCKStubAction>)action;


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)invocation;

- (void)applyToInvocation:(NSInvocation *)invocation;

@end


@interface MCKStubInvocationPrototpye : NSObject

@property (nonatomic, readonly) NSInvocation *invocation;
@property (nonatomic, readonly) NSArray      *primitiveArgumentMatchers;

- (id)initWithInvocation:(NSInvocation *)invocation primitiveArgumentMatchers:(NSArray *)argumentMatchers;

@end
