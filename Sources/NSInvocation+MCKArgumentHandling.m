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

- (NSInteger)mck_integerArgumentAtEffectiveIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(NSInteger, index);
}

- (NSUInteger)mck_unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index {
    ReturnArgumentAtEffectiveIndex(NSUInteger, index);
}


#pragma mark - Nice Syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX

- (NSInteger)integerArgumentAtEffectiveIndex:(NSUInteger)index { return [self mck_integerArgumentAtEffectiveIndex:index]; }
- (NSUInteger)unsignedIntegerArgumentAtEffectiveIndex:(NSUInteger)index { return [self mck_unsignedIntegerArgumentAtEffectiveIndex:index]; }

#endif

@end


@interface NSInvocation_MCKArgumentHandling_LinkerBug : NSObject
@end
@implementation NSInvocation_MCKArgumentHandling_LinkerBug
@end
