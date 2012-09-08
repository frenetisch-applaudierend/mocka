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
        
        if ([RGMockTypeEncodings isPrimitiveType:candidateArgumentType]) {
            UInt64 candidateArgument = 0; [candidate getArgument:&candidateArgument atIndex:argIndex];
            UInt64 prototypeArgument = 0; [prototype getArgument:&prototypeArgument atIndex:argIndex];
            if (prototypeArgument != AnyIntMagicNumber && candidateArgument != prototypeArgument) {
                return NO;
            }
        } else if ([RGMockTypeEncodings isObjectType:candidateArgumentType]) {
            void *candidateArgument = nil; [candidate getArgument:&candidateArgument atIndex:argIndex];
            void *prototypeArgument = nil; [prototype getArgument:&prototypeArgument atIndex:argIndex];
            if (candidateArgument != prototypeArgument && ![(__bridge id)candidateArgument isEqual:(__bridge id)prototypeArgument]) {
                return NO;
            }
        } else if ([RGMockTypeEncodings isSelectorOrCStringType:candidateArgumentType]) {
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

@end
