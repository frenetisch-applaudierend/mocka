//
//  RGMockInvocationMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface RGMockInvocationMatcher : NSObject

+ (id)defaultMatcher;

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype;

- (BOOL)isPrimitiveType:(const char *)type;
- (BOOL)isObjectType:(const char *)type;
- (BOOL)isSelectorOrCStringType:(const char *)type;
- (BOOL)isVoidType:(const char *)type;
- (const char *)typeBySkippingTypeModifiers:(const char *)type;
@end
