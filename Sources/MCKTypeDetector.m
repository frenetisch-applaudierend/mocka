//
//  MCKTypeDetector.m
//  mocka
//
//  Created by Markus Gasser on 22.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKTypeDetector.h"
#import <objc/runtime.h>


@implementation MCKTypeDetector

+ (BOOL)isClass:(id)object {
    return class_isMetaClass(object_getClass(object));
}

+ (BOOL)isProtocol:(id)object {
    return (object_getClass(object) == object_getClass(@protocol(NSObject)));
}

+ (BOOL)isObject:(id)object {
    return !([self isClass:object] || [self isProtocol:object]);
}

@end
