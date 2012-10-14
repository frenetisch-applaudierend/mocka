//
//  MockTestObject.h
//  mocka
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class TestObject;

#define AssertNumberOfInvocations(obj, num) \
    STAssertEquals([TestObjectCalledSelectors((obj)) count], (NSUInteger)(num), @"Expected different call count")
#define AssertSelectorCalledAtIndex(obj, sel, idx) \
    STAssertEqualObjects(TestObjectCalledSelectors((obj))[(idx)], NSStringFromSelector((sel)), @"Selector not called at this index")
#define AssertSelectorNotCalled(obj, sel) \
    STAssertFalse([TestObjectCalledSelectors((obj)) containsObject:NSStringFromSelector((sel))], @"Selector was called")

NSArray* TestObjectCalledSelectors(TestObject *object);


@interface TestObject : NSObject

#pragma mark - Void Return Calls

- (void)voidMethodCallWithoutParameters;
- (void)voidMethodCallWithIntParam1:(int)i1 intParam2:(int)i2;
- (void)voidMethodCallWithObjectParam1:(id)o1 objectParam2:(id)o2;
- (void)voidMethodCallWithSelectorParam1:(SEL)s1 selectorParam2:(SEL)s2;
- (void)voidMethodCallWithCStringParam1:(char *)s1 cStringParam2:(char *)s2;
- (void)voidMethodCallWithPointerParam1:(void *)p1 pointerParam2:(void *)p2;

- (void)voidMethodCallWithObjectParam1:(id)o1 intParam2:(int)i2;


#pragma mark - Int Return Calls

- (int)intMethodCallWithoutParameters;


#pragma mark - Object Return Calls

- (id)objectMethodCallWithoutParameters;


#pragma mark - Pointer Return Calls

- (int *)intPointerMethodCallWithoutParameters;


#pragma mark - Struct Return Calls

- (NSRange)rangeMethodCallWithoutParameters;

@end
