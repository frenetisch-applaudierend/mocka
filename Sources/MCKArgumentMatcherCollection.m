//
//  MCKArgumentMatcherCollection.m
//  mocka
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKArgumentMatcherCollection.h"
#import "MCKTypeEncodings.h"


@implementation MCKArgumentMatcherCollection {
    NSMutableArray *_primitiveArgumentMatchers;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _primitiveArgumentMatchers = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Adding Matchers

- (NSArray *)primitiveArgumentMatchers {
    return [_primitiveArgumentMatchers copy];
}

- (void)addPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if ([_primitiveArgumentMatchers count] > UINT8_MAX) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Only UINT8_MAX primitive matchers supported" userInfo:nil];
    }
    [_primitiveArgumentMatchers addObject:matcher];
}

- (UInt8)lastPrimitiveArgumentMatcherIndex {
    NSAssert([_primitiveArgumentMatchers count] > 0, @"Cannot return last argument index when no arguments were added");
    return ([_primitiveArgumentMatchers count] - 1);
}

- (void)resetAllMatchers {
    [_primitiveArgumentMatchers removeAllObjects];
}


#pragma mark - Validating the Collection

- (BOOL)isValidForMethodSignature:(NSMethodSignature *)signature {
    if ([_primitiveArgumentMatchers count] == 0) {
        return YES;
    }
    return ([self countPrimitiveArgumentsOfSignature:signature] == [_primitiveArgumentMatchers count]);
}

- (NSUInteger)countPrimitiveArgumentsOfSignature:(NSMethodSignature *)signature {
    NSUInteger primitiveArgumentCount = 0;
    for (NSUInteger argIndex = 2; argIndex < [signature numberOfArguments]; argIndex++) {
        if (![MCKTypeEncodings isObjectType:[signature getArgumentTypeAtIndex:argIndex]]) {
            primitiveArgumentCount++;
        }
    }
    return primitiveArgumentCount;
}

@end
