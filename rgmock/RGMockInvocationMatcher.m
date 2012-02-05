//
//  RGMockInvocationMatcher.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationMatcher.h"


static BOOL isEncodedType(char typeChar) {
    return (typeChar != 'r' && typeChar != 'R' &&
            typeChar != 'n' && typeChar != 'N' &&
            typeChar != 'o' && typeChar != 'O' &&
            typeChar != 'V');
    
}

static BOOL equalTypes(const char *t1, const char *t2) {
    NSMutableString *type1 = [NSMutableString string];
    NSMutableString *type2 = [NSMutableString string];
    for (int i = 0; i < strlen(t1); i++) { if (isEncodedType(t1[i])) { [type1 appendFormat:@"%c", t1[i]]; } }
    for (int i = 0; i < strlen(t2); i++) { if (isEncodedType(t2[i])) { [type2 appendFormat:@"%c", t2[i]]; } }
    return ([type1 isEqualToString:type2]);
}


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
    if (equalTypes(argType, @encode(id))) {
        id value1, value2;
        [invocation1 getArgument:&value1 atIndex:index];
        [invocation2 getArgument:&value2 atIndex:index];
        return (value1 != nil ? [value1 isEqual:value2] : value2 == nil);
    } else if (equalTypes(argType, @encode(BOOL))) {
        BOOL value1, value2;
        [invocation1 getArgument:&value1 atIndex:index];
        [invocation2 getArgument:&value2 atIndex:index];
        return (value1 == value2);
    } else if (equalTypes(argType, @encode(_Bool))) {
        _Bool value1, value2;
        [invocation1 getArgument:&value1 atIndex:index];
        [invocation2 getArgument:&value2 atIndex:index];
        return (value1 == value2);
    } else {
        NSString *reason = [NSString stringWithFormat:@"Cannot match argument at index %d with type %s", (index - 2), argType];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
}

@end
