//
//  RGMockArgumentMatcherCollection.m
//  rgmock
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockArgumentMatcherCollection.h"
#import "RGMockTypeEncodings.h"


@implementation RGMockArgumentMatcherCollection {
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

- (void)addPrimitiveArgumentMatcher:(id<RGMockArgumentMatcher>)matcher {
    [_primitiveArgumentMatchers addObject:matcher];
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
        if (![RGMockTypeEncodings isObjectType:[signature getArgumentTypeAtIndex:argIndex]]) {
            primitiveArgumentCount++;
        }
    }
    return primitiveArgumentCount;
}

@end
