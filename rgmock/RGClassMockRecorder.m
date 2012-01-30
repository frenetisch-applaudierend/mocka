//
//  RGClassMockObject.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGClassMockRecorder.h"

@interface RGClassMockRecorder () {
@private
    Class _mockedClass;
}
@end


@implementation RGClassMockRecorder

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


#pragma mark - Mocking the passed Class

- (BOOL)respondsToSelector:(SEL)selector {
    return [_mockedClass instancesRespondToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [_mockedClass instanceMethodSignatureForSelector:selector];
}

@end
