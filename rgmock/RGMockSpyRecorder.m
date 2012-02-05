//
//  RGMockSpyRecorder.m
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockSpyRecorder.h"
#import <objc/runtime.h>


static const char *RelayerTarget = "relayerTarget";


@interface RGMockSpyRelayer : NSObject

+ (id)relayerOverwritingExistingObject:(id<NSObject>)object withTarget:(id<NSObject>)target;

@end



@interface RGMockSpyRecorder () {
@private
    id _realObject;
    id _relayer;
}
@end

@implementation RGMockSpyRecorder

#pragma mark - Initialization

+ (id)mockRecorderForSpyingObject:(id<NSObject>)object {
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id<NSObject>)object {
    if ((self = [super init])) {
        _realObject = object_copy(object, class_getInstanceSize(object.class));
        _relayer = [RGMockSpyRelayer relayerOverwritingExistingObject:object withTarget:self];
    }
    return self;
}

- (void)dealloc {
    [_realObject dealloc];
    [_relayer dealloc];
    [super dealloc];
}


#pragma mark - Responding to Methods

- (BOOL)respondsToSelector:(SEL)selector {
    return ([super respondsToSelector:selector] || [_realObject respondsToSelector:selector]);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil) {
        signature = [_realObject methodSignatureForSelector:selector];
    }
    return signature;
}


@end


#pragma mark -
@implementation RGMockSpyRelayer


#pragma mark - Creating a Relayer

+ (id)relayerOverwritingExistingObject:(id<NSObject>)object withTarget:(id<NSObject>)target {
    // We can only override an object with an instance size smaller or equal to our own
    // because we need to override the objects content later
    if (class_getInstanceSize(object.class) < class_getInstanceSize(self)) {
        NSString *reason = [NSString stringWithFormat:@"Cannot override object %@ because it's too small", object];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Create the instance and replace the existing object with it
    RGMockSpyRelayer *relayer = [[[self alloc] init] autorelease];
    memcpy((void *)object, (const void *)relayer, class_getInstanceSize(self));
    
    // Mark the target for the relayer to use
    // We don't use an ivar for this, since it would increase the instance size
    objc_setAssociatedObject(object, RelayerTarget, target, OBJC_ASSOCIATION_RETAIN);
    return object;
}


#pragma mark - Managing Method Calls

- (BOOL)respondsToSelector:(SEL)selector {
    return [objc_getAssociatedObject(self, RelayerTarget) respondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [objc_getAssociatedObject(self, RelayerTarget) methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    invocation.target = objc_getAssociatedObject(self, RelayerTarget);
    [invocation.target forwardInvocation:invocation];
}

- (id)self {
    return [objc_getAssociatedObject(self, RelayerTarget) self];
}


#pragma mark - Memory Management and Debugging

- (oneway void)release {
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p: %@>", self.class, self, objc_getAssociatedObject(self, RelayerTarget)];
}

@end
