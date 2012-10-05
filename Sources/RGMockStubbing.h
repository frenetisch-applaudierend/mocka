//
//  RGMockStubbing.h
//  rgmock
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RGMockStubAction;


@interface RGMockStubbing : NSObject


#pragma mark - Initialization and Configuration

- (void)addInvocation:(NSInvocation *)invocation withNonObjectArgumentMatchers:(NSArray *)argumentMatchers;
- (void)addAction:(id<RGMockStubAction>)action;


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)invocation;

- (void)applyToInvocation:(NSInvocation *)invocation;

@end