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

- (__autoreleasing id)mck_objectParameterAtIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(__autoreleasing id, index);
}

- (NSInteger)mck_integerParameterAtIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(NSInteger, index);
}

- (NSUInteger)mck_unsignedIntegerParameterAtIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(NSUInteger, index);
}

- (void *)mck_structParameter:(out void *)parameter atIndex:(NSUInteger)index {
    [self getArgument:parameter atIndex:(index + 2)];
    return parameter;
}

#pragma mark - Setting Return Value

- (void)mck_setObjectReturnValue:(id)value {
    [self setReturnValue:&value];
}


#pragma mark - Argument Information

- (NSUInteger)mck_sizeofParameterAtIndex:(NSUInteger)index {
    NSUInteger size = 0;
    NSGetSizeAndAlignment([self.methodSignature getArgumentTypeAtIndex:(index + 2)], &size, NULL);
    return size;
}


#pragma mark - Nice Syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX

- (id)objectParameterAtIndex:(NSUInteger)index { return [self mck_objectParameterAtIndex:index]; }
- (NSInteger)integerParameterAtIndex:(NSUInteger)index { return [self mck_integerParameterAtIndex:index]; }
- (NSUInteger)unsignedIntegerParameterAtIndex:(NSUInteger)index { return [self mck_unsignedIntegerParameterAtIndex:index]; }
- (void *)structParameter:(out void *)parameter atIndex:(NSUInteger)index { return [self mck_structParameter:parameter atIndex:index]; }
- (void)setObjectReturnValue:(id)value { [self mck_setObjectReturnValue:value]; }
- (NSUInteger)sizeofParameterAtIndex:(NSUInteger)index { return [self mck_sizeofParameterAtIndex:index]; }

#endif

@end
