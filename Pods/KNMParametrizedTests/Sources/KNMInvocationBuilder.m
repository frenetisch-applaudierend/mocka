//
//  KNMInvocationBuilder.m
//  KNMParametrizedTests
//
//  Created by Markus Gasser on 24.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "KNMInvocationBuilder.h"
#import "KNMParametrizedTestsValues.h"


#define TypeIs(ENC, T) (strcmp((ENC), @encode(T)) == 0)


@implementation KNMInvocationBuilder

#pragma mark - Initialization

+ (instancetype)builder
{
    static KNMInvocationBuilder *builder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        builder = [[KNMInvocationBuilder alloc] init];
    });
    return builder;
}


#pragma mark - Building Invocations

- (NSInvocation *)buildTestInvocationForSelector:(SEL)selector inClass:(Class)cls withParameter:(id)parameter
{
    NSMethodSignature *signature = [cls instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    [self setParameter:parameter forInvocation:invocation];
    
    return invocation;
}

- (void)setParameter:(id)parameter forInvocation:(NSInvocation *)invocation
{
    if (parameter == knm_NIL) {
        return; // nil value
    }
    
    
    const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:2];
    
    // object type
    if (TypeIs(argType, id) || TypeIs(argType, Class)) {
        [invocation setArgument:(void *)&parameter atIndex:2];
        return;
    }
    
    // scalar types
    if (![parameter isKindOfClass:[NSValue class]]) {
        NSString *reason = [NSString stringWithFormat:@"Scalar values must be wrapped in NSValue or a subclass (param was %@)", [parameter class]];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    if (TypeIs(argType, int8_t) || TypeIs(argType, uint8_t) || TypeIs(argType, BOOL) || TypeIs(argType, bool)) {
        uint8_t value = (uint8_t)[parameter unsignedLongLongValue];
        [invocation setArgument:(void *)&value atIndex:2];
    }
    else if (TypeIs(argType, int16_t) || TypeIs(argType, uint16_t)) {
        uint16_t value = (uint16_t)[parameter unsignedLongLongValue];
        [invocation setArgument:(void *)&value atIndex:2];
    }
    else if (TypeIs(argType, int32_t) || TypeIs(argType, uint32_t)) {
        uint32_t value = (uint32_t)[parameter unsignedLongLongValue];
        [invocation setArgument:(void *)&value atIndex:2];
    }
    else if (TypeIs(argType, int64_t) || TypeIs(argType, uint64_t)) {
        uint64_t value = (uint64_t)[parameter unsignedLongLongValue];
        [invocation setArgument:(void *)&value atIndex:2];
    }
    else if (strcmp([parameter objCType], argType) == 0) {
        NSUInteger size;
        NSGetSizeAndAlignment(argType, &size, NULL);
        
        UInt8 buffer[size]; memset(buffer, 0, size);
        [parameter getValue:buffer];
        [invocation setArgument:buffer atIndex:2];
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Incompatible parameter types (%s vs %s)", argType, [parameter objCType]];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
}

@end
