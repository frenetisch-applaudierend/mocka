//
//  MockTestObject.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface MockTestObject : NSObject

#pragma mark - Void Return Calls

- (void)voidMethodCallWithoutParameters;
- (void)voidMethodCallWithIntParam1:(int)i1 intParam2:(int)i2;
- (void)voidMethodCallWithObjectParam1:(id)o1 objectParam2:(id)o2;
- (void)voidMethodCallWithSelectorParam1:(SEL)s1 selectorParam2:(SEL)s2;
- (void)voidMethodCallWithCStringParam1:(SEL)s1 cStringParam2:(SEL)s2;


#pragma mark - Int Return Calls

- (int)intMethodCallWithoutParameters;


#pragma mark - Object Return Calls

- (id)objectMethodCallWithoutParameters;

@end
