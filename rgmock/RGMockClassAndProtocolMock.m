//
//  RGClassMock.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockClassAndProtocolMock.h"
#import "RGMockContext.h"

#import <objc/runtime.h>

static BOOL isProtocol(id obj);
static BOOL isClass(id obj);


@implementation RGMockClassAndProtocolMock {
    RGMockContext *_mockingContext;
    NSArray       *_mockedEntities;
}

#pragma mark - Initialization

+ (id)mockWithContext:(RGMockContext *)context classAndProtocols:(NSArray *)sourceList {
    return [[self alloc] initWithContext:context classAndProtocols:sourceList];
}

- (id)initWithContext:(RGMockContext *)context classAndProtocols:(NSArray *)sourceList {
    // Sanity check on the source list
    if ([sourceList count] == 0) {
        [context failWithReason:@"Need at least one class or protocol for mocking"];
    }
    for (id object in sourceList) {
        if (!(isProtocol(object) || isClass(object))) {
            [context failWithReason:@"Only Class or Protocol instances can be mocked. To mock an existing object use spy()"];
        }
    }
    
    // Full initialization
    if ((self = [super init])) {
        _mockingContext = context;
        _mockedEntities = [sourceList copy];
    }
    return self;
}


#pragma mark - Handling Invocations

- (BOOL)respondsToSelector:(SEL)selector {
    if ([super respondsToSelector:selector]) {
        return YES;
    }
    return ([self methodSignatureForSelector:selector] != nil);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature != nil) {
        return signature;
    }
    
    for (id entity in _mockedEntities) {
        NSMethodSignature *signature = (isClass(entity)
                                        ? [self methodSignatureForSelector:selector ofClass:entity]
                                        : [self methodSignatureForSelector:selector ofProtocol:entity]);
        if (signature != nil) {
            return signature;
        }
    }
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector ofClass:(Class)cls {
    return [cls instanceMethodSignatureForSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector ofProtocol:(Protocol *)protocol {
    struct objc_method_description method = protocol_getMethodDescription(protocol, selector, YES, YES);
    if (method.name == NULL) {
        method = protocol_getMethodDescription(protocol, selector, NO, YES);
    }
    return (method.name != NULL ? [NSMethodSignature signatureWithObjCTypes:method.types] : nil);
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [_mockingContext handleInvocation:invocation];
}


#pragma mark - Posing as the mocked class / protocol

- (BOOL)isKindOfClass:(Class)cls {
    if ([super isKindOfClass:cls]) {
        return YES;
    }
    
    NSUInteger firstMatch = [_mockedEntities indexOfObjectPassingTest:^BOOL(id entity, NSUInteger idx, BOOL *stop) {
        if (!isClass(entity)) { return NO; }
        Class candidate = entity;
        do {
            if (candidate == cls) { return YES; }
            candidate = class_getSuperclass(candidate);
        } while(candidate != nil);
        return NO;
    }];
    return (firstMatch != NSNotFound);
}

- (BOOL)conformsToProtocol:(Protocol *)prot {
    if ([super conformsToProtocol:prot]) {
        return YES;
    }
    
    NSUInteger firstMatch = [_mockedEntities indexOfObjectPassingTest:^BOOL(id candidate, NSUInteger idx, BOOL *stop) {
        if (candidate == prot) { return YES; }
        if (isClass(candidate) && [candidate conformsToProtocol:prot]) { return YES; }
        NSAssert(isProtocol(candidate), @"Candidate was not a class or protocol");
        return protocol_conformsToProtocol((Protocol *)candidate, prot);
        
    }];
    return (firstMatch != NSNotFound);
}

@end


#pragma mark - Helper Functions

static BOOL isProtocol(id obj) {
    return (object_getClass(obj) == object_getClass(@protocol(NSObject)));
}

static BOOL isClass(id obj) {
    return class_isMetaClass(object_getClass(obj));
}
