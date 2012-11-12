//
//  MCKArgumentMatcherCollection.h
//  mocka
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKArgumentMatcher;


@interface MCKArgumentMatcherCollection : NSObject


#pragma mark - Managing Matchers

@property (nonatomic, readonly, copy) NSArray *primitiveArgumentMatchers;

- (void)addPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher;
- (UInt8)lastPrimitiveArgumentMatcherIndex;
- (void)resetAllMatchers;


#pragma mark - Validating the Collection

- (BOOL)isValidForMethodSignature:(NSMethodSignature *)signature;

@end
