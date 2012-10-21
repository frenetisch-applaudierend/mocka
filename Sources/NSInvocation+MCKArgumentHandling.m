//
//  NSInvocation+MCKArgumentHandling.m
//  mocka
//
//  Created by Markus Gasser on 19.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "NSInvocation+MCKArgumentHandling.h"

#define ReturnArgumentAtEffectiveIndex(type, idx) {\
    type value = (type)0;\
    [self getArgument:&value atIndex:((idx) + 2)];\
    return value;\
}


@implementation NSInvocation (MCKArgumentHandling)

#pragma mark - Retrieving Arguments

- (id)mck_objectArgumentAtEffectiveIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(id, index);
}

- (NSInteger)mck_integerArgumentAtEffectiveIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(NSInteger, index);
}

- (NSUInteger)mck_unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(NSUInteger, index);
}


#pragma mark - Setting Return Value

- (void)mck_setObjectReturnValue:(id)value {
    [self setReturnValue:&value];
}


#pragma mark - Nice Syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX

- (id)objectArgumentAtEffectiveIndex:(NSUInteger)index { return [self mck_objectArgumentAtEffectiveIndex:index]; }
- (NSInteger)integerArgumentAtEffectiveIndex:(NSUInteger)index { return [self mck_integerArgumentAtEffectiveIndex:index]; }
- (NSUInteger)unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index { return [self mck_unsignedIntegerArgumentAtEffectiveIndex:index]; }

- (void)setObjectReturnValue:(id)value { [self mck_setObjectReturnValue:value]; }

#endif

@end
