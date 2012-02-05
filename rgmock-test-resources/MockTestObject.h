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

- (void)methodCallWithInt1:(int)int1 int2:(int)int2;
- (void)methodCallWithUInt1:(unsigned int)int1 UInt2:(unsigned int)int2;
- (void)methodCallWithShort1:(short)int1 short2:(short)int2;
- (void)methodCallWithUShort1:(unsigned short)int1 UShort2:(unsigned short)int2;
- (void)methodCallWithLong1:(long)int1 long2:(long)int2;
- (void)methodCallWithULong1:(unsigned long)int1 ULong2:(unsigned long)int2;
- (void)methodCallWithLongLong1:(long long)int1 longLong2:(long long)int2;
- (void)methodCallWithULongLong1:(unsigned long long)int1 ULongLong2:(unsigned long long)int2;

- (void)methodCallWithFloat1:(float)int1 float2:(float)int2;
- (void)methodCallWithDouble1:(double)int1 Double2:(double)int2;

- (void)methodCallWithCString1:(const char *)str1 CString2:(const char *)str2;

@end
