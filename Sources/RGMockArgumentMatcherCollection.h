//
//  RGMockArgumentMatcherCollection.h
//  rgmock
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RGMockArgumentMatcher;


@interface RGMockArgumentMatcherCollection : NSObject


#pragma mark - Managing Matchers

@property (nonatomic, readonly) NSMutableArray *nonObjectArgumentMatchers;

- (void)addPrimitiveArgumentMatcher:(id<RGMockArgumentMatcher>)matcher;


#pragma mark - Validating the Collection

- (BOOL)isValidForMethodSignature:(NSMethodSignature *)signature;

@end
