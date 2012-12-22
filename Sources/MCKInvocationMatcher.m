//
//  MCKInvocationMatcher.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationMatcher.h"
#import "MCKTypeEncodings.h"
#import "MCKArgumentMatcher.h"
#import "MCKArgumentSerialization.h"
#import "MCKExactArgumentMatcher.h"
#import "MCKHamcrestArgumentMatcher.h"
#import "NSInvocation+MCKArgumentHandling.h"
#import <objc/runtime.h>


@implementation MCKInvocationMatcher

#pragma mark - Initialization

+ (id)matcher {
    static id sharedMatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMatcher = [[MCKInvocationMatcher alloc] init];
    });
    return sharedMatcher;
}


#pragma mark - Invocation Matching

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)argumentMatchers {
    NSParameterAssert(candidate != nil);
    NSParameterAssert(prototype != nil);
    
    // check if the structure of the candidate and prototype are even the same
    if (![self candidate:candidate canMatch:prototype]) {
        return NO;
    }
    
    // match all arguments
    NSArray *orderedArgumentMatchers = [self orderedArgumentMatchersFromPrototype:prototype primitiveArgumentMatchers:argumentMatchers];
    for (NSUInteger argIndex = 2; argIndex < prototype.methodSignature.numberOfArguments; argIndex++) {
        id<MCKArgumentMatcher> matcher = [orderedArgumentMatchers objectAtIndex:(argIndex - 2)];
        id candidateValue = [self serializedValueForArgumentAtIndex:argIndex ofInvocation:candidate];
        if (![matcher matchesCandidate:candidateValue]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)candidate:(NSInvocation *)candidate canMatch:(NSInvocation *)prototype {
    if (candidate.target != prototype.target || candidate.selector != prototype.selector) {
        return NO;
    }
    
    NSAssert(candidate.methodSignature.numberOfArguments == prototype.methodSignature.numberOfArguments, @"Different number of arguments");
    for (NSUInteger argIndex = 2; argIndex < prototype.methodSignature.numberOfArguments; argIndex++) {
        if (strcmp([candidate.methodSignature getArgumentTypeAtIndex:argIndex], [prototype.methodSignature getArgumentTypeAtIndex:argIndex]) != 0) {
            return NO;
        }
    }
    
    return YES;
}

- (NSArray *)orderedArgumentMatchersFromPrototype:(NSInvocation *)prototype primitiveArgumentMatchers:(NSArray *)primitiveMatchers {
    NSMutableArray *matchers = [NSMutableArray arrayWithCapacity:(prototype.methodSignature.numberOfArguments - 2)];
    for (NSUInteger argIndex = 2; argIndex < prototype.methodSignature.numberOfArguments; argIndex++) {
        if ([MCKTypeEncodings isObjectType:[prototype.methodSignature getArgumentTypeAtIndex:argIndex]]) {
            [matchers addObject:[self wrapObjectInMatcherIfNeeded:[prototype mck_objectParameterAtIndex:(argIndex - 2)]]];
        } else if ([primitiveMatchers count] > 0) {
            [matchers addObject:[primitiveMatchers objectAtIndex:[self primitiveMatcherIndexFromPrototype:prototype argumentIndex:argIndex]]];
        } else {
            id value = [self serializedValueForArgumentAtIndex:argIndex ofInvocation:prototype];
            [matchers addObject:[MCKExactArgumentMatcher matcherWithArgument:value]];
        }
    }
    return matchers;
}

- (id<MCKArgumentMatcher>)wrapObjectInMatcherIfNeeded:(id)object {
    if ([object conformsToProtocol:@protocol(MCKArgumentMatcher)]) {
        return object;
    } else if ([self hamcrestMatcherProtocol] != nil && [object conformsToProtocol:[self hamcrestMatcherProtocol]]) {
        return [MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:object];
    } else {
        return [MCKExactArgumentMatcher matcherWithArgument:object];
    }
}

- (NSUInteger)primitiveMatcherIndexFromPrototype:(NSInvocation *)prototype argumentIndex:(NSUInteger)argIndex {
    NSUInteger paramSize = [prototype mck_sizeofParameterAtIndex:(argIndex - 2)];
    NSAssert(paramSize >= 1, @"Minimum byte size not given");
    UInt8 buffer[paramSize]; memset(buffer, 0, paramSize);
    [prototype getArgument:buffer atIndex:argIndex];
    return mck_matcherIndexForArgumentBytes(buffer, [prototype.methodSignature getArgumentTypeAtIndex:argIndex]);
}

- (id)serializedValueForArgumentAtIndex:(NSUInteger)argIndex ofInvocation:(NSInvocation *)invocation {
    NSUInteger paramSize = [invocation mck_sizeofParameterAtIndex:(argIndex - 2)];
    UInt8 buffer[paramSize]; memset(buffer, 0, paramSize);
    [invocation getArgument:buffer atIndex:argIndex];
    return mck_encodeValueFromBytesAndType(buffer, paramSize, [invocation.methodSignature getArgumentTypeAtIndex:argIndex]);
}


#pragma mark - Helpers

- (Protocol *)hamcrestMatcherProtocol {
    static Protocol *hamcrestProtocol = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hamcrestProtocol = objc_getProtocol("HCMatcher");
    });
    return hamcrestProtocol;
}

@end
