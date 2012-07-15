//
//  RGClassMock.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGClassAndProtocolMock.h"
#import "RGMockingContext.h"


@implementation RGClassAndProtocolMock {
    RGMockingContext *_mockingContext;
    Class             _mockedClass;
}

#pragma mark - Initialization

+ (id)mockWithContext:(RGMockingContext *)context classAndProtocols:(NSArray *)sourceList {
    return [[self alloc] initWithContext:context classAndProtocols:sourceList];
}

- (id)initWithContext:(RGMockingContext *)context classAndProtocols:(NSArray *)sourceList {
    if ((self = [super init])) {
        _mockingContext = context;
        _mockedClass = [sourceList lastObject];
    }
    return self;
}


#pragma mark - Handling Invocations

- (BOOL)respondsToSelector:(SEL)selector {
    return ([super respondsToSelector:selector] || [_mockedClass instancesRespondToSelector:selector]);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil) {
        signature = [_mockedClass instanceMethodSignatureForSelector:selector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [_mockingContext handleInvocation:invocation];
}

@end
