//
//  NSInvocation+MCKArgumentHandling.h
//  mocka
//
//  Created by Markus Gasser on 19.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSInvocation (MCKArgumentHandling)

#pragma mark - Getting Parameters

// Getting typed parameters (shorthand around -getArgument:atIndex:)
// Note: self and _cmd are not counted as "parameter" and therefore
//       index 0 is the first parameter, not self, so you don't need
//       to add 2 to get to the right parameter

- (id)mck_objectParameterAtIndex:(NSUInteger)index;
- (NSInteger)mck_integerParameterAtIndex:(NSUInteger)index;
- (NSUInteger)mck_unsignedIntegerParameterAtIndex:(NSUInteger)index;
- (void *)mck_structParameter:(out void *)parameter atIndex:(NSUInteger)index;


#pragma mark - Setting the Return Value

- (void)mck_setObjectReturnValue:(id)value;

@end

#define mck_structParameter(inv, idx, structType) (*((structType *)([(inv) mck_structParameter:&(structType){} atIndex:(idx)])))


#ifndef MOCK_DISABLE_NICE_SYNTAX
@interface NSInvocation (MCKArgumentHandling_NiceSyntax)

- (id)objectParameterAtIndex:(NSUInteger)index;
- (NSInteger)integerParameterAtIndex:(NSUInteger)index;
- (NSUInteger)unsignedIntegerParameterAtIndex:(NSUInteger)index;
- (void *)structParameter:(out void *)parameter atIndex:(NSUInteger)index;

- (void)setObjectReturnValue:(id)value;

@end

#define structParameter(inv, idx, structType) mck_structParameter(inv, idx, structType)

#endif
