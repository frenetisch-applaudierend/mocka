//
//  MCKMockObject.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockObject.h"
#import "MCKMockingContext.h"
#import "MCKTypeDetector.h"
#import "MCKAPIMisuse.h"

#import <objc/runtime.h>


@implementation MCKMockObject {
    MCKMockingContext *_mockingContext;
    Class _mockedClass;
    NSArray *_mockedProtocols;
}

#pragma mark - Building a Mock

+ (id)mockWithContext:(MCKMockingContext *)context entities:(NSArray *)sourceList
{
    [self checkSourceListIsSane:sourceList];
    
    return [[self alloc] initWithContext:context
                             mockedClass:[self mockedClassInSourceList:sourceList]
                         mockedProtocols:[self mockedProtocolsInSourceList:sourceList]];
}

+ (void)checkSourceListIsSane:(NSArray *)sourceList
{
    [self checkHasAtLeastOneEntityInSourceList:sourceList];
    [self checkHasOnlyMockableEntitiesInSourceList:sourceList];
    [self checkHasAtMostOneClassInSourceList:sourceList];
}

+ (void)checkHasAtLeastOneEntityInSourceList:(NSArray *)sourceList
{
    if ([sourceList count] == 0) {
        MCKAPIMisuse(@"Need at least one class or protocol for mocking");
    }
}

+ (void)checkHasOnlyMockableEntitiesInSourceList:(NSArray *)sourceList
{
    for (id entity in sourceList) {
        if (![self entityIsMockable:entity]) {
            MCKAPIMisuse(@"Only Class or Protocol instances can be mocked. To mock an existing object use spy()");
        }
    }
}

+ (void)checkHasAtMostOneClassInSourceList:(NSArray *)sourceList
{
    BOOL hasClass = NO;
    for (id entity in sourceList) {
        if ([MCKTypeDetector isClass:entity]) {
            if (hasClass) {
                MCKAPIMisuse(@"At most one class can be mocked.");
            }
            hasClass = YES;
        }
    }
}

+ (Class)mockedClassInSourceList:(NSArray *)sourceList
{
    NSParameterAssert([sourceList count] > 0);
    
    for (id entity in sourceList) {
        if ([MCKTypeDetector isClass:entity]) {
            return entity;
        }
    }
    return nil;
}

+ (NSArray *)mockedProtocolsInSourceList:(NSArray *)sourceList
{
    NSParameterAssert([sourceList count] > 0);
    
    return ([MCKTypeDetector isClass:[sourceList objectAtIndex:0]] ? [sourceList subarrayWithRange:NSMakeRange(1, [sourceList count] - 1)] : sourceList);
}

+ (BOOL)entityIsMockable:(id)entity
{
    return ([MCKTypeDetector isClass:entity] || [MCKTypeDetector isProtocol:entity]);
}


#pragma mark - Initialization

- (id)initWithContext:(MCKMockingContext *)context mockedClass:(Class)cls mockedProtocols:(NSArray *)protocols
{
    if ((self = [super init])) {
        _mockingContext = context;
        _mockedClass = cls;
        _mockedProtocols = [protocols copy];
    }
    return self;
}


#pragma mark - Handling Invocations

- (BOOL)respondsToSelector:(SEL)selector
{
    if ([super respondsToSelector:selector]) {
        return YES;
    }
    return ([self methodSignatureForSelector:selector] != nil);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature;
    
    signature = [super methodSignatureForSelector:selector];
    if (signature != nil) {
        return signature;
    }
    
    signature = [self mck_methodSignatureForSelector:selector ofClass:_mockedClass];
    if (signature != nil) {
        return signature;
    }
    
    for (Protocol *protocol in _mockedProtocols) {
        signature = [self mck_methodSignatureForSelector:selector ofProtocol:protocol];
        if (signature != nil) {
            return signature;
        }
    }
    
    return nil;
}

- (NSMethodSignature *)mck_methodSignatureForSelector:(SEL)selector ofClass:(Class)cls
{
    return [cls instanceMethodSignatureForSelector:selector];
}

- (NSMethodSignature *)mck_methodSignatureForSelector:(SEL)selector ofProtocol:(Protocol *)protocol
{
    struct objc_method_description method = protocol_getMethodDescription(protocol, selector, YES, YES);
    if (method.name == NULL) {
        method = protocol_getMethodDescription(protocol, selector, NO, YES);
    }
    return (method.name != NULL ? [NSMethodSignature signatureWithObjCTypes:method.types] : nil);
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [_mockingContext handleInvocation:invocation];
}


#pragma mark - Posing as the mocked class / protocol

- (BOOL)isKindOfClass:(Class)cls
{
    return ([super isKindOfClass:cls] || [_mockedClass isSubclassOfClass:cls]);
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    if ([super conformsToProtocol:protocol] || [_mockedClass conformsToProtocol:protocol]) {
        return YES;
    }
    
    for (Protocol *candidate in _mockedProtocols) {
        if (protocol_conformsToProtocol(candidate, protocol)) {
            return YES;
        }
    }
    
    return NO;
}


#pragma mark - Debugging

- (NSArray *)mck_mockedEntites
{
    NSMutableArray *mockedEntities = [NSMutableArray array];
    if (_mockedClass != nil) {
        [mockedEntities addObject:_mockedClass];
    }
    [mockedEntities addObjectsFromArray:_mockedProtocols];
    return [mockedEntities copy];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale
{
    return [NSString stringWithFormat:@"<mock{%@%@}: %p>", [self mck_mockedClassName], [self mck_mockedProtocolList], self];
}

- (NSString *)mck_mockedClassName
{
    return (_mockedClass != nil ? NSStringFromClass(_mockedClass) : @"id");
}

- (NSString *)mck_mockedProtocolList
{
    if ([_mockedProtocols count] == 0) {
        return @"";
    }
    
    NSMutableArray *protocolNames = [NSMutableArray arrayWithCapacity:[_mockedProtocols count]];
    for (Protocol *protocol in _mockedProtocols) {
        [protocolNames addObject:[NSString stringWithUTF8String:protocol_getName(protocol)]];
    }
    return [NSString stringWithFormat:@"<%@>", [protocolNames componentsJoinedByString:@", "]];
}

@end
