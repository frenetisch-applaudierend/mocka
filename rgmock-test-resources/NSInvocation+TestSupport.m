//
//  NSInvocation+TestSupport.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "NSInvocation+TestSupport.h"

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


@implementation NSInvocation (TestSupport)

+ (id)invocationForTarget:(id)target selectorAndArguments:(SEL)selector, ... {
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [self invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = target;
    
    // Add arguments
    va_list args;
    va_start(args, selector);
    for (NSUInteger argIndex = 2; argIndex < [signature numberOfArguments]; argIndex++) {
        #define matchArgs(...) __VA_ARGS__
        #define matchArg(t) if (equalTypes(argType, @encode(t))) { t arg = va_arg(args, t); [invocation setArgument:&arg atIndex:argIndex]; } \
                            else if (equalTypes(argType, @encode(t*))) { t* arg = va_arg(args, t*); [invocation setArgument:&arg atIndex:argIndex]; } \
                            else if (equalTypes(argType, @encode(t[]))) { t* arg = va_arg(args, t*); [invocation setArgument:&arg atIndex:argIndex]; }
        const char *argType = [signature getArgumentTypeAtIndex:argIndex];
        
        matchArgs(
                  matchArg(__unsafe_unretained id) else matchArg(__unsafe_unretained Class) else matchArg(SEL)
                  else matchArg(char) else matchArg(unsigned char)
                  else matchArg(int) else matchArg(unsigned int)
                  else matchArg(short) else matchArg(unsigned short)
                  else matchArg(long) else matchArg(unsigned long)
                  else matchArg(long long) else matchArg(unsigned long long)
                  else matchArg(float) else matchArg(double)
                  else matchArg(_Bool) else matchArg(bool)
        )
    }
    va_end(args);
    
    return invocation;
}

@end
