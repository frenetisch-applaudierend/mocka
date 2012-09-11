//
//  RGMockInvocationMatcher.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationMatcher.h"
#import "RGMockTypeEncodings.h"
#import "RGMockArgumentMatcher.h"


@implementation RGMockInvocationMatcher

#pragma mark - Initialization

+ (id)defaultMatcher {
    static id defaultMatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultMatcher = [[RGMockInvocationMatcher alloc] init];
    });
    
    return defaultMatcher;
}


#pragma mark - Invocation Matching

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype withNonObjectArgumentMatchers:(NSArray *)argumentMatchers {
    // Check for the most obvious failures
    if (candidate == nil || prototype == nil || candidate.target != prototype.target || candidate.selector != prototype.selector) {
        return NO;
    }
    
    // Sanity check => if this fails, something is seriously broken
    NSAssert(candidate.methodSignature.numberOfArguments == prototype.methodSignature.numberOfArguments,
             @"Same selector but different number of arguments");
    
    // Check arguments (first two can be skipped, it's self and _cmd)
    for (NSUInteger argIndex = 2; argIndex < prototype.methodSignature.numberOfArguments; argIndex++) {
        // Test for argument types
        const char *candidateArgumentType = [candidate.methodSignature getArgumentTypeAtIndex:argIndex];
        const char *prototypeArgumentType = [prototype.methodSignature getArgumentTypeAtIndex:argIndex];
        if (strcmp(candidateArgumentType, prototypeArgumentType) != 0) {
            return NO;
        }
        
        if ([RGMockTypeEncodings isObjectType:candidateArgumentType]) {
            if (![self matchesObjectArgumentAtIndex:argIndex forCandidate:candidate prototype:prototype]) {
                return NO;
            }
        } else if ([RGMockTypeEncodings isPrimitiveType:candidateArgumentType]) {
            if (![self matchesPrimitiveArgumentAtIndex:argIndex forCandidate:candidate prototype:prototype argumentMatchers:argumentMatchers]) {
                return NO;
            }
        } else if ([RGMockTypeEncodings isSelectorOrCStringType:candidateArgumentType]) {
            if (![self matchesCStringArgumentAtIndex:argIndex forCandidate:candidate prototype:prototype argumentMatchers:argumentMatchers]) {
                return NO;
            }
        } else if ([RGMockTypeEncodings isPointerType:candidateArgumentType]) {
            if (![self matchesPointerArgumentAtIndex:argIndex forCandidate:candidate prototype:prototype argumentMatchers:argumentMatchers]) {
                return NO;
            }
        } else {
            NSLog(@"Invocation Matcher: ignoring unknown objc type %s", candidateArgumentType);
        }
    }
    return YES;
}

- (BOOL)matchesObjectArgumentAtIndex:(NSUInteger)argIndex
                        forCandidate:(NSInvocation *)candidate
                           prototype:(NSInvocation *)prototype
{
    void *candidateArgumentPtr = nil; [candidate getArgument:&candidateArgumentPtr atIndex:argIndex];
    void *prototypeArgumentPtr = nil; [prototype getArgument:&prototypeArgumentPtr atIndex:argIndex];
    id candidateArgument = (__bridge id)candidateArgumentPtr;
    id prototypeArgument = (__bridge id)prototypeArgumentPtr;
    
    if ([prototypeArgument conformsToProtocol:@protocol(RGMockArgumentMatcher)]) {
        return [(id<RGMockArgumentMatcher>)prototypeArgument matchesCandidate:candidateArgument];
    } else {
        return (candidateArgument == prototypeArgument || [candidateArgument isEqual:prototypeArgument]);
    }
}

- (BOOL)matchesPrimitiveArgumentAtIndex:(NSUInteger)argIndex
                           forCandidate:(NSInvocation *)candidate
                              prototype:(NSInvocation *)prototype
                       argumentMatchers:(NSArray *)argumentMatchers
{
    UInt64 candidateArgument = 0; [candidate getArgument:&candidateArgument atIndex:argIndex];
    UInt64 prototypeArgument = 0; [prototype getArgument:&prototypeArgument atIndex:argIndex];
    
    if ([argumentMatchers count] > 0) {
        id<RGMockArgumentMatcher> matcher = argumentMatchers[(char)prototypeArgument];
        return [matcher matchesCandidate:@(candidateArgument)];
    } else {
        return (candidateArgument == prototypeArgument);
    }
}

- (BOOL)matchesCStringArgumentAtIndex:(NSUInteger)argIndex
                         forCandidate:(NSInvocation *)candidate
                            prototype:(NSInvocation *)prototype
                     argumentMatchers:(NSArray *)argumentMatchers
{
    const char *candidateArgument = NULL; [candidate getArgument:&candidateArgument atIndex:argIndex];
    const char *prototypeArgument = NULL; [prototype getArgument:&prototypeArgument atIndex:argIndex];
    
    if ([argumentMatchers count] > 0) {
        id<RGMockArgumentMatcher> matcher = argumentMatchers[(UInt8)(prototypeArgument)];
        return [matcher matchesCandidate:[NSValue valueWithPointer:candidateArgument]];
    } else {
        return (candidateArgument == prototypeArgument || strcmp(candidateArgument, prototypeArgument) == 0);
    }
}

- (BOOL)matchesPointerArgumentAtIndex:(NSUInteger)argIndex
                         forCandidate:(NSInvocation *)candidate
                            prototype:(NSInvocation *)prototype
                     argumentMatchers:(NSArray *)argumentMatchers
{
    const void *candidateArgument = NULL; [candidate getArgument:&candidateArgument atIndex:argIndex];
    const void *prototypeArgument = NULL; [prototype getArgument:&prototypeArgument atIndex:argIndex];
    
    if ([argumentMatchers count] > 0) {
        id<RGMockArgumentMatcher> matcher = argumentMatchers[(UInt8)prototypeArgument];
        return [matcher matchesCandidate:[NSValue valueWithPointer:candidateArgument]];
    } else {
        return (candidateArgument == prototypeArgument);
    }
}

@end
