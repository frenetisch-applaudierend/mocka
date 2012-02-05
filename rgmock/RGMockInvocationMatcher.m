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
    #define runChecks(...) __VA_ARGS__
    #define checkMatchesPrimitive(t)\
        if (equalTypes(argType, @encode(t))) {\
            t v1, v2; [invocation1 getArgument:&v1 atIndex:index]; [invocation2 getArgument:&v2 atIndex:index]; return (v1 == v2);\
        }
    
    runChecks(
              // Handle objects specially
              if (equalTypes(argType, @encode(id))) {
                  id value1, value2;
                  [invocation1 getArgument:&value1 atIndex:index];
                  [invocation2 getArgument:&value2 atIndex:index];
                  return (value1 != nil ? [value1 isEqual:value2] : value2 == nil);
              }
              
              // Handle strings
              else if (equalTypes(argType, @encode(char*))) {
                  char *value1, *value2;
                  [invocation1 getArgument:&value1 atIndex:index];
                  [invocation2 getArgument:&value2 atIndex:index];
                  return (value1 == value2 || (value1 != NULL && value2 != NULL && strcmp(value1, value2) == 0));
              }
              
              // Handle other special types
              else checkMatchesPrimitive(Class)     else checkMatchesPrimitive(SEL)
              
              // Handle primitive types
              else checkMatchesPrimitive(BOOL)      else checkMatchesPrimitive(_Bool)
              else checkMatchesPrimitive(char)      else checkMatchesPrimitive(unsigned char)
              else checkMatchesPrimitive(int)       else checkMatchesPrimitive(unsigned int)
              else checkMatchesPrimitive(short)     else checkMatchesPrimitive(unsigned short)
              else checkMatchesPrimitive(long)      else checkMatchesPrimitive(unsigned long)
              else checkMatchesPrimitive(long long) else checkMatchesPrimitive(unsigned long long)
              else checkMatchesPrimitive(float)     else checkMatchesPrimitive(double)
              
              else {
                  NSString *reason = [NSString stringWithFormat:@"Cannot match argument at index %d with type %s", (index - 2), argType];
                  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
              }
    );
}

@end
