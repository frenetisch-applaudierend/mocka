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
    char type = [[RGMockInvocationMatcher defaultMatcher] typeBySkippingTypeModifiers:invocation.methodSignature.methodReturnType][0];
    switch (type) {
        case 'c': { char c = [_value charValue]; [invocation setReturnValue:&c]; break; }
        default:
            [invocation setReturnValue:&_value];
    }
}

@end
