//
//  MockTestObject.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface MockTestObject : NSObject

- (void)simpleMethodCall;

- (void)methodCallWithObject1:(id)object1 object2:(id)object2 object3:(id)object3;

- (void)methodCallWithBool1:(BOOL)bool1 bool2:(BOOL)bool2;
- (void)methodCallWithCBool1:(_Bool)bool1 CBool2:(_Bool)bool2;
- (void)methodCallWithCppBool1:(bool)bool1 CppBool2:(bool)bool2;

@end
