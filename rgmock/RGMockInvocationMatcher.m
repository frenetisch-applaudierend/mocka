//
//  RGMockInvocationMatcher.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationMatcher.h"


@interface RGMockInvocationMatcher ()

- (BOOL)argumentAtIndex:(NSUInteger)index withType:(const char *)argType
    isEqualInInvocation:(NSInvocation *)invocation1 andInvocation:(NSInvocation *)invocation2;

@end


@implementation RGMockInvocationMatcher

- (BOOL)invocation:(NSInvocation *)invocation matchesInvocation:(NSInvocation *)candidate {
    // First check for obvious mismatches
    if (!(invocation.selector == candidate.selector
          && invocation.target == candidate.target
          && [invocation.methodSignature isEqual:candidate.methodSignature]))
    {
        return NO;
    }
    
    // Check if parameter match
    NSMethodSignature *signature = invocation.methodSignature;
    for (NSUInteger argIndex = 2; argIndex < [signature numberOfArguments]; argIndex++) {
        if (![self argumentAtIndex:argIndex withType:[signature getArgumentTypeAtIndex:argIndex]
               isEqualInInvocation:invocation andInvocation:candidate])
        {
            return NO;
        }
    }
    
    // All good, we have a match
    return YES;
}

- (BOOL)argumentAtIndex:(NSUInteger)index withType:(const char *)argType
    isEqualInInvocation:(NSInvocation *)invocation1 andInvocation:(NSInvocation *)invocation2
{
#define argumentTypeIs(t) (*argType == *@encode(t))
    
    if (argumentTypeIs(id)) {
        id value1, value2;
        [invocation1 getArgument:&value1 atIndex:index];
        [invocation2 getArgument:&value2 atIndex:index];
        return (value1 != nil ? [value1 isEqual:value2] : value2 == nil);
    } else {
        NSString *reason = [NSString stringWithFormat:@"Cannot match objects of type %s", argType];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
}

@end
