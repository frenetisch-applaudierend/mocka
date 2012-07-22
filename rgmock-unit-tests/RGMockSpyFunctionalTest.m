//
//  RGMockSpyFunctionalTest.m
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockTestingUtils.h"
#import "MockTestObject.h"

#import "RGMock.h"

#define AssertNumberOfInvocations(obj, num) STAssertEquals([MockTestObjectCalledSelectors((obj)) count], (NSUInteger)(num),\
    @"Expected different call count")
#define AssertSelectorCalledAtIndex(obj, sel, idx) STAssertEqualObjects(MockTestObjectCalledSelectors((obj))[(idx)], NSStringFromSelector((sel)),\
    @"Selector not called at this index")
#define AssertSelectorNotCalled(obj, sel) STAssertFalse([MockTestObjectCalledSelectors((obj)) containsObject:NSStringFromSelector((sel))],\
    @"Selector was called")


@interface RGMockSpyFunctionalTest : SenTestCase
@end

@implementation RGMockSpyFunctionalTest {
    MockTestObject *object;
}


#pragma mark - Setup

- (void)setUp {
    [super setUp];
    object = spy([[MockTestObject alloc] init]);
}


#pragma mark - Test Simple Verify

- (void)testThatVerifySucceedsForSimpleCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}

- (void)testThatVerifyFailsForMissingMethodCall {
    // then
    AssertFails({
        verify [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatVerifySucceedsForTwoCallsAndTwoVerifies {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 2);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 1);
}

- (void)testThatVerifyFailsIfAppliedTwiceToOneCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
    AssertFails({
        verify [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}


#pragma mark - Test Verify with handlers

- (void)testThatVerifyNeverFailsWhenCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verify never [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}

- (void)testThatVerifyNeverSucceedsWhenNoCallWasMade {
    AssertDoesNotFail({
        verify never [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatExactlyOneSucceedsWhenOneCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify exactly(1) [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
}

- (void)testThatExactlyOneFailsWhenNoCallWasMade {
    AssertFails({
        verify exactly(1) [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatExactlyOneFailsWhenMultipleCallsWereMade {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verify exactly(1) [object voidMethodCallWithoutParameters];
    });
    
    AssertNumberOfInvocations(object, 2);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 0);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithoutParameters), 1);
}


#pragma mark - Test Stubbing

- (void)testThatUnstubbedMethodsReturnOriginalValues {
    MockTestObject *referenceObject = [[MockTestObject alloc] init];
    
    STAssertEqualObjects([object objectMethodCallWithoutParameters], [referenceObject objectMethodCallWithoutParameters], @"Should return reference value for unstubbed object return");
    STAssertEquals([object intMethodCallWithoutParameters], [referenceObject intMethodCallWithoutParameters], @"Should return reference value for unstubbed int return");
    STAssertEquals([object intPointerMethodCallWithoutParameters], [referenceObject intPointerMethodCallWithoutParameters], @"Should return reference value for unstubbed pointer return");
    STAssertTrue(NSEqualRanges([object rangeMethodCallWithoutParameters], [referenceObject rangeMethodCallWithoutParameters]), @"Should return reference value for unstubbed range");
}

- (void)testThatStubbedReturnValueIsReturned {
    // given
    stub [object objectMethodCallWithoutParameters]; soThatItWill returnValue(@"Hello World");
    
    // when
    id result = [object objectMethodCallWithoutParameters];
    
    // then
    STAssertEqualObjects(result, @"Hello World", @"Wrong object value returned");
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testMultipleStubActions {
    // given
    __block NSString *marker = nil;
    stub [object objectMethodCallWithoutParameters];
    soThatItWill performBlock(^(NSInvocation *inv) {
        marker = @"called";
    });
    andItWill returnValue(@20);
    
    // then
    STAssertEqualObjects([object objectMethodCallWithoutParameters], @20, @"Wrong return value");
    STAssertEqualObjects(marker, @"called", @"Marker was not set or wrongly set");
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatSubsequentStubbingsDontInterfere {
    // given
    MockTestObject *object1 = spy([[MockTestObject alloc] init]);
    MockTestObject *object2 = spy([[MockTestObject alloc] init]);
    MockTestObject *object3 = spy([[MockTestObject alloc] init]);
    MockTestObject *object4 = spy([[MockTestObject alloc] init]);
    MockTestObject *refObject = [[MockTestObject alloc] init];
    __block NSString *marker = nil;
    
    // when
    stub [object1 objectMethodCallWithoutParameters]; soThatItWill returnValue(@"First Object");
    stub [object2 objectMethodCallWithoutParameters]; soThatItWill returnValue(@"Second Object");
    stub [object3 objectMethodCallWithoutParameters]; soThatItWill performBlock(^(NSInvocation *inv) {
        marker = @"Third Object";
    });
    
    [object4 objectMethodCallWithoutParameters];
    
    
    // then
    STAssertEqualObjects([object1 objectMethodCallWithoutParameters], @"First Object", @"Wrong return value for object");
    STAssertNil(marker, @"Marker was set too early");
    
    STAssertEqualObjects([object2 objectMethodCallWithoutParameters], @"Second Object", @"Wrong return value for object");
    STAssertNil(marker, @"Marker was set too early");
    
    STAssertNil([object3 objectMethodCallWithoutParameters], @"Wrong return value for object");
    STAssertEqualObjects(marker, @"Third Object", @"Marker was not set or wrongly set");
    
    STAssertEqualObjects([object4 objectMethodCallWithoutParameters], [refObject objectMethodCallWithoutParameters], @"Non-stubbed call was suddenly stubbed");
    
    AssertNumberOfInvocations(object1, 0);
    AssertNumberOfInvocations(object2, 0);
    AssertNumberOfInvocations(object3, 0);
    
    AssertNumberOfInvocations(object4, 2);
    AssertSelectorCalledAtIndex(object4, @selector(objectMethodCallWithoutParameters), 0);
    AssertSelectorCalledAtIndex(object4, @selector(objectMethodCallWithoutParameters), 1);
}

- (void)testThatLaterStubbingsOverrideOlderStubbingsOfSameInvocation {
    // given
    __block NSString *marker = nil;
    stub [object objectMethodCallWithoutParameters];
    soThatItWill performBlock(^(NSInvocation *inv) {
        marker = @"called";
    });
    andItWill returnValue(@20);
    
    // when
    stub [object objectMethodCallWithoutParameters]; soThatItWill returnValue(@30);
    
    // then
    STAssertEqualObjects([object objectMethodCallWithoutParameters], @30, @"Wrong return value for object");
    STAssertNil(marker, @"Marker was set");
    
    AssertNumberOfInvocations(object, 0);
}

- (void)testThatMultipleStubbingsCanBeCombined {
    // given
    MockTestObject *object1 = spy([[MockTestObject alloc] init]);
    MockTestObject *object2 = spy([[MockTestObject alloc] init]);
    
    // when
    stub {
        [object1 objectMethodCallWithoutParameters];
        [object2 objectMethodCallWithoutParameters];
    };
    soThatItWill returnValue(@10);
    
    // then
    STAssertEqualObjects([object1 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
    STAssertEqualObjects([object2 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
    
    AssertNumberOfInvocations(object1, 0);
    AssertNumberOfInvocations(object2, 0);
}

- (void)testStubbingArray {
    // given
    NSMutableArray *array = spy([NSMutableArray array]);
    
    stub [array count];
    soThatItWill performBlock(^(NSInvocation *inv) { [self description]; });
    andItWill returnValue(10);
    
    // then
    STAssertEquals((int)[array count], (int)10, @"[array count] stub does not work");
}

- (void)testStubbingConstantString {
    // given
    NSString *string = spy(@"Hello");
    
    stub [string length];
    soThatItWill returnValue(99);
    
    // then
    STAssertEquals((int)[string length], (int)99, @"[string length] stub does not work");
}

@end
