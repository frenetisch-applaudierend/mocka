//
//  RGMockReturnStubAction.m
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockReturnStubAction.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockReturnStubAction {
    id _value;
}

#pragma mark - Initialization

+ (id)returnActionWithValue:(id)value {
    return [[self alloc] initWithValue:value];
}

- (id)initWithValue:(id)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}


#pragma mark - Performing the Action

- (void)performWithInvocation:(NSInvocation *)invocation {
    // Safeguard agains void returns
    if ([[RGMockInvocationMatcher defaultMatcher] isVoidType:invocation.methodSignature.methodReturnType]) {
        return;
    }
    
    // Handle primitive and object types
    #define HandlePrimitive(code, type, sel) case code: { type value = [_value sel]; [invocation setReturnValue:&value]; break; }
    char type = [[RGMockInvocationMatcher defaultMatcher] typeBySkippingTypeModifiers:invocation.methodSignature.methodReturnType][0];
    switch (type) {
            HandlePrimitive('c', char, charValue)
            HandlePrimitive('s', short, shortValue)
            HandlePrimitive('i', int, intValue)
            HandlePrimitive('l', long, longValue)
            HandlePrimitive('q', long long, unsignedLongLongValue)
            HandlePrimitive('C', unsigned char, unsignedCharValue)
            HandlePrimitive('S', unsigned short, unsignedShortValue)
            HandlePrimitive('I', unsigned int, unsignedIntValue)
            HandlePrimitive('L', unsigned long, unsignedLongValue)
            HandlePrimitive('Q', unsigned long long, unsignedLongLongValue)
            HandlePrimitive('f', float, floatValue)
            HandlePrimitive('d', double, doubleValue)
            
        default:
            [invocation setReturnValue:&_value];
    }
}

@end
