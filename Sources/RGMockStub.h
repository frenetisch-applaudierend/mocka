//
//  RGMockStubbing.h
//  rgmock
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RGMockInvocationMatcher;
@protocol RGMockStubAction;


@interface RGMockStub : NSObject

#pragma mark - Initialization

- (id)initWithInvocationMatcher:(RGMockInvocationMatcher *)invocationMatcher;


#pragma mark - Configuration

@property (nonatomic, readonly, copy) NSArray *invocationPrototypes;
@property (nonatomic, readonly, copy) NSArray *actions;

- (void)addInvocation:(NSInvocation *)invocation withPrimitiveArgumentMatchers:(NSArray *)argumentMatchers;
- (void)addAction:(id<RGMockStubAction>)action;


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)invocation;

- (void)applyToInvocation:(NSInvocation *)invocation;

@end


@interface RGMockStubInvocationPrototpye : NSObject

@property (nonatomic, readonly) NSInvocation *invocation;
@property (nonatomic, readonly) NSArray      *primitiveArgumentMatchers;

- (id)initWithInvocation:(NSInvocation *)invocation primitiveArgumentMatchers:(NSArray *)argumentMatchers;

@end
