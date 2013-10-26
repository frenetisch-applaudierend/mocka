//
//  MCKSetOutParameterStubAction.h
//  mocka
//
//  Created by Markus Gasser on 21.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKStubAction.h"


@interface MCKSetOutParameterStubAction : NSObject <MCKStubAction>

+ (id)actionToSetObject:(id)value atEffectiveIndex:(NSUInteger)index;
- (id)initWithIndex:(NSUInteger)index objectValue:(id)value;

@end


// Mocking Syntax
extern void mck_setOutParameterAtIndex(NSUInteger index, id value);

#ifndef MCK_DISABLE_NICE_SYNTAX

    extern void setOutParameterAtIndex(NSUInteger index, id value);

#endif
