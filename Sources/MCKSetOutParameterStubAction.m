//
//  MCKSetOutParameterStubAction.m
//  mocka
//
//  Created by Markus Gasser on 21.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKSetOutParameterStubAction.h"

@implementation MCKSetOutParameterStubAction {
    NSUInteger _argumentIndex;
    id _value;
}

#pragma mark - Initialization

+ (id)actionToSetObject:(id)value atEffectiveIndex:(NSUInteger)index {
    return [[self alloc] initWithIndex:(index + 2) objectValue:value];
}

- (id)initWithIndex:(NSUInteger)index objectValue:(id)value {
    if ((self = [super init])) {
        _argumentIndex = index;
        _value = value;
    }
    return self;
}


#pragma mark - Performing the Invocation

- (void)performWithInvocation:(NSInvocation *)invocation {
    id __autoreleasing *outParameter = NULL;
    [invocation getArgument:&outParameter atIndex:_argumentIndex];
    if (outParameter != NULL) {
        *outParameter = _value;
    }
}

@end


#pragma mark - Mocking Syntax

void mck_setOutParameterAtIndex(NSUInteger index, id value) {
    _mck_addStubAction([MCKSetOutParameterStubAction actionToSetObject:value atEffectiveIndex:index]);
}


#ifndef MCK_DISABLE_NICE_SYNTAX

    void setOutParameterAtIndex(NSUInteger index, id value) {
        mck_setOutParameterAtIndex(index, value);
    }

#endif
