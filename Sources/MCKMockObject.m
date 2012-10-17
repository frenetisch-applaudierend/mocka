//
//  MCKMockObject.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockObject.h"
#import "MCKMockingContext.h"

#import <objc/runtime.h>

static BOOL isProtocol(id obj);
static BOOL isClass(id obj);


@implementation MCKMockObject {
    NSArray *_mockedEntities;
    MCKMockingContext *_mockingContext;
}

#pragma mark - Initialization

+ (id)mockWithContext:(MCKMockingContext *)context classAndProtocols:(NSArray *)sourceList {
    if (![self sourceListIsSane:sourceList context:context]) {
        return nil;
    }
    return [[self alloc] initWithContext:context mockedEntities:sourceList];
}

+ (BOOL)sourceListIsSane:(NSArray *)sourceList context:(MCKMockingContext *)context {
    return ([self hasAtLeastOneEntityInSourceList:sourceList context:context]
            && [self hasOnlyClassAndProtocolObjectsInSourceList:sourceList context:context]
            && [self mockedClassIsAbsentOrAtFirstPositionInSourceList:sourceList context:context]);
}

+ (BOOL)hasAtLeastOneEntityInSourceList:(NSArray *)sourceList context:(MCKMockingContext *)context {
    if ([sourceList count] == 0) {
        [context failWithReason:@"Need at least one class or protocol for mocking"];
        return NO;
    }
    return YES;
}

+ (BOOL)hasOnlyClassAndProtocolObjectsInSourceList:(NSArray *)sourceList context:(MCKMockingContext *)context {
    for (id object in sourceList) {
        if (!(isProtocol(object) || isClass(object))) {
            [context failWithReason:@"Only Class or Protocol instances can be mocked. To mock an existing object use spy()"];
            return NO;
        }
    }
    return YES;
}

+ (BOOL)mockedClassIsAbsentOrAtFirstPositionInSourceList:(NSArray *)sourceList context:(MCKMockingContext *)context {
    NSEnumerator *entityEnumerator = [sourceList objectEnumerator];
    [entityEnumerator nextObject]; // skip the first object since it's irrelevant if it's a protocol or a class
    
    // Other entities must not be classes
    for (id object in entityEnumerator) {
        if (isClass(object)) {
            [context failWithReason:@"If you mock a class it must be at the first position"];
            return NO;
        }
    }
    return YES;
}

- (id)initWithContext:(MCKMockingContext *)context mockedEntities:(NSArray *)mockedEntities {
    if ((self = [super init])) {
        _mockingContext = context;
        _mockedEntities = [mockedEntities copy];
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


#pragma mark - Debugging

- (NSArray *)mck_mockedEntites {
    return [_mockedEntities copy];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale {
    return [NSString stringWithFormat:@"<mock{%@%@}: %p>", [self mck_mockedClassName], [self mck_mockedProtocolList], self];
}

- (NSString *)mck_mockedClassName {
    for (id mockedEntity in _mockedEntities) {
        if (isClass(mockedEntity)) {
            return NSStringFromClass(mockedEntity);
        }
    }
    return @"id";
}

- (NSString *)mck_mockedProtocolList {
    NSMutableArray *protocols = [NSMutableArray array];
    for (id mockedEntity in _mockedEntities) {
        if (isProtocol(mockedEntity)) {
            [protocols addObject:NSStringFromProtocol(mockedEntity)];
        }
    }
    return ([protocols count] == 0 ? @"" : [NSString stringWithFormat:@"<%@>", [protocols componentsJoinedByString:@", "]]);
}

@end


#pragma mark - Helper Functions

static BOOL isProtocol(id obj) {
    return (object_getClass(obj) == object_getClass(@protocol(NSObject)));
}

static BOOL isClass(id obj) {
    return class_isMetaClass(object_getClass(obj));
}
