//
//  MCKSetOutParameterStubAction.h
//  mocka
//
//  Created by Markus Gasser on 21.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKStubAction.h"
#import "MCKMockingContext.h"


@interface MCKSetOutParameterStubAction : NSObject <MCKStubAction>

+ (id)actionToSetObject:(id)value atEffectiveIndex:(NSUInteger)index;
- (id)initWithIndex:(NSUInteger)index objectValue:(id)value;

@end


// Mocking Syntax
static inline void mck_setOutParameterAtIndex(NSUInteger index, id value) {
    [[MCKMockingContext currentContext] addStubAction:[MCKSetOutParameterStubAction actionToSetObject:value atEffectiveIndex:index]];
}

#ifndef MOCK_DISABLE_NICE_SYNTAX

static inline void setOutParameterAtIndex(NSUInteger index, id value) {
    mck_setOutParameterAtIndex(index, value);
}

#endif
