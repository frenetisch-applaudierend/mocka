//
//  RGMockInvocationMatcher.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationMatcher.h"

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

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype {
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
        
        if ([self isPrimitiveType:candidateArgumentType]) {
            UInt64 candidateArgument = 0; [candidate getArgument:&candidateArgument atIndex:argIndex];
            UInt64 prototypeArgument = 0; [prototype getArgument:&prototypeArgument atIndex:argIndex];
            if (candidateArgument != prototypeArgument) {
                return NO;
            }
        } else if ([self isObjectType:candidateArgumentType]) {
            void *candidateArgument = nil; [candidate getArgument:&candidateArgument atIndex:argIndex];
            void *prototypeArgument = nil; [prototype getArgument:&prototypeArgument atIndex:argIndex];
            if (candidateArgument != prototypeArgument && ![(__bridge id)candidateArgument isEqual:(__bridge id)prototypeArgument]) {
                return NO;
            }
        } else if ([self isSelectorOrCStringType:candidateArgumentType]) {
            // Seems like C strings are reported as selectors, so treat both of them like C strings
            const char *candidateArgument = NULL; [candidate getArgument:&candidateArgument atIndex:argIndex];
            const char *prototypeArgument = NULL; [prototype getArgument:&prototypeArgument atIndex:argIndex];
            if (candidateArgument != prototypeArgument && strcmp(candidateArgument, prototypeArgument) != 0) {
                return NO;
            }
        } else {
            NSLog(@"Invocation Matcher: ignoring unknown objc type %s", candidateArgumentType);
        }
    }
    return YES;
}


#pragma mark - Helpers

- (BOOL)isPrimitiveType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    switch (type[0]) {
        // Primitive type encodings
        case 'c': case 'i': case 's': case 'l': case 'q':
        case 'C': case 'I': case 'S': case 'L': case 'Q':
        case 'f': case 'd':
        case 'B':
            return YES;
            
        default:
            return NO;
    }
}

- (BOOL)isObjectType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    type = [self typeBySkippingTypeModifiers:type];
    return (type[0] == '@' || type[0] == '#');
}

- (BOOL)isSelectorOrCStringType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    return (type[0] == ':' || type[0] == '*'); // * never gets reported strangely, c strings are reported as : as well
}

- (const char *)typeBySkippingTypeModifiers:(const char *)type {
    while (type[0] == 'r' || type[0] == 'n' || type[0] == 'N' || type[0] == 'o' || type[0] == 'O' || type[0] == 'R' || type[0] == 'V') {
        type++;
    }
    return type;
}

@end
