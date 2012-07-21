//
//  RGMockThrowExceptionStubAction.m
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockThrowExceptionStubAction.h"

@implementation RGMockThrowExceptionStubAction {
    id _exception;
}

#pragma mark - Initialization

+ (id)throwExceptionActionWithException:(id)exception {
    return [[self alloc] initWithException:exception];
}

- (id)initWithException:(id)exception {
    if ((self = [super init])) {
        _exception = exception;
    }
    return self;
}


#pragma mark - Performing the Action

- (void)performWithInvocation:(NSInvocation *)invocation {
    @throw _exception;
}

@end
