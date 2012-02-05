//
//  RGClassMockObject.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockClassRecorder.h"

@interface RGMockClassRecorder () {
@private
    Class _mockedClass;
}
@end


@implementation RGMockClassRecorder

#pragma mark - Initialization

+ (id)mockRecorderForClass:(Class)cls {
    return [[self alloc] initWithClass:cls];
}

- (id)initWithClass:(Class)cls {
    if ((self = [super init])) {
        _mockedClass = cls;
    }
    return self;
}


#pragma mark - Responding to Methods

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

@end
