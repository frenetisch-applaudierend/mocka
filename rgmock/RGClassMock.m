//
//  RGClassMock.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGClassMock.h"
#import "RGMockingContext.h"

@interface RGClassMock ()

@property (nonatomic, strong) Class             mockedClass;
@property (nonatomic, strong) RGMockingContext *mockingContext;

@end


@implementation RGClassMock

#pragma mark - Initialization

+ (id)mockForClass:(Class)cls context:(RGMockingContext *)context {
    return [[self alloc] initWithMockedClass:cls context:context];
}

- (id)initWithMockedClass:(Class)cls context:(RGMockingContext *)context {
    if ((self = [super init])) {
        self.mockedClass = cls;
        self.mockingContext = context;
    }
    return self;
}


#pragma mark - Handling Invocations

- (BOOL)respondsToSelector:(SEL)selector {
    return ([super respondsToSelector:selector] || [self.mockedClass instancesRespondToSelector:selector]);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil) {
        signature = [self.mockedClass instanceMethodSignatureForSelector:selector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self.mockingContext handleInvocation:invocation];
}

@end
