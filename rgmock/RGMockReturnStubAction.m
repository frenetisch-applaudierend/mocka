//
//  RGMockReturnStubAction.m
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockReturnStubAction.h"
#import "RGMockTypeEncodings.h"


@implementation RGMockReturnStubAction {
    NSValue *_value;
}

#pragma mark - Initialization

+ (id)returnActionWithValue:(NSValue *)value {
    return [[self alloc] initWithValue:value];
}

- (id)initWithValue:(NSValue *)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}


#pragma mark - Performing the Action

- (void)performWithInvocation:(NSInvocation *)invocation {
    // Safeguard agains void returns
    if (isVoidType(invocation.methodSignature.methodReturnType)) {
        return;
    }
    
    // Handle primitive and object types
    #define HandlePrimitive(code, type, sel) case code: { type value = [(NSNumber *)_value sel]; [invocation setReturnValue:&value]; break; }
    char type = typeBySkippingTypeModifiers(invocation.methodSignature.methodReturnType)[0];
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
            
//        default:
//            [invocation setReturnValue:&_value];
    }
}

@end
