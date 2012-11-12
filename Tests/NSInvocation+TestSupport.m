//
//  NSInvocation+TestSupport.m
//  mocka
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "NSInvocation+TestSupport.h"
#import "MCKTypeEncodings.h"


@implementation NSInvocation (TestSupport)

+ (id)invocationForTarget:(id)target selectorAndArguments:(SEL)selector, ... {
    NSParameterAssert(target != nil);
    NSParameterAssert(selector != NULL);
    
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [self invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = target;
    
    // Add arguments
    va_list args;
    va_start(args, selector);
    [invocation readArgumentFromVarargs:args];
    va_end(args);
    
    [invocation retainArguments];
    return invocation;
}

+ (id)voidMethodInvocationForTarget:(id)target {
    NSInvocation *invocation = [self invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    invocation.target = target;
    return invocation;
}

- (void)readArgumentFromVarargs:(va_list)args {
    for (NSUInteger argIndex = 2; argIndex < [self.methodSignature numberOfArguments]; argIndex++) {
        const char *argType = [self.methodSignature getArgumentTypeAtIndex:argIndex];
        
        if ([MCKTypeEncodings isObjectType:argType]) {
            id arg = va_arg(args, id);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isPointerType:argType]) {
            void *arg = va_arg(args, void*);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isSelectorType:argType]) {
            SEL arg = va_arg(args, SEL);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isCStringType:argType]) {
            char *arg = va_arg(args, char*);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isType:argType equalToType:@encode(char)] || [MCKTypeEncodings isType:argType equalToType:@encode(unsigned char)]
                   || [MCKTypeEncodings isType:argType equalToType:@encode(short)] || [MCKTypeEncodings isType:argType equalToType:@encode(unsigned short)]
                   || [MCKTypeEncodings isType:argType equalToType:@encode(int)] || [MCKTypeEncodings isType:argType equalToType:@encode(unsigned int)])
        {
            int arg = va_arg(args, int);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isType:argType equalToType:@encode(long)] || [MCKTypeEncodings isType:argType equalToType:@encode(unsigned long)]) {
            unsigned long arg = va_arg(args, unsigned long);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isType:argType equalToType:@encode(long long)] || [MCKTypeEncodings isType:argType equalToType:@encode(unsigned long long)]) {
            unsigned long long arg = va_arg(args, unsigned long long);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isType:argType equalToType:@encode(float)] || [MCKTypeEncodings isType:argType equalToType:@encode(double)]) {
            double arg = va_arg(args, double);
            [self setArgument:&arg atIndex:argIndex];
        } else if ([MCKTypeEncodings isType:argType equalToType:@encode(_Bool)] || [MCKTypeEncodings isType:argType equalToType:@encode(bool)]) {
            int arg = va_arg(args, int);
            [self setArgument:&arg atIndex:argIndex];
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unknown argument type" userInfo:nil];
        }
    }
}


#pragma mark - Convenience Getters

#define GetterImpl(type) - (type)type ## ArgumentAtIndex:(NSInteger)index { type arg; [self getArgument:&arg atIndex:index]; return arg; }
#define GetterImpl2(type, name) - (type)name ## ArgumentAtIndex:(NSInteger)index { type arg; [self getArgument:&arg atIndex:index]; return arg; }

GetterImpl(int);
GetterImpl2(unsigned int, unsignedInt);
GetterImpl2(const char *, cString);
GetterImpl2(void *, pointer);

@end
