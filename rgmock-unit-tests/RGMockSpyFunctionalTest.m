//
//  RGMockSpyFunctionalTest.m
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockTestCase.h"
#import "MockTestObject.h"

#import "RGMock.h"

#define AssertNumberOfInvocations(obj, num) STAssertEquals([MockTestObjectCalledSelectors((obj)) count], (NSUInteger)(num),\
    @"Expected different call count")
#define AssertSelectorCalledAtIndex(obj, sel, idx) STAssertEqualObjects(MockTestObjectCalledSelectors((obj))[(idx)], NSStringFromSelector((sel)),\
    @"Selector not called at this index")
#define AssertSelectorNotCalled(obj, sel) STAssertFalse([MockTestObjectCalledSelectors((obj)) containsObject:NSStringFromSelector((sel))],\
    @"Selector was called")


@interface RGMockSpyFunctionalTest : RGMockTestCase
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


#pragma mark - Test Verify with Arguments

- (void)testThatVerifySucceedsForMatchingObjectArguments {
    // when
    [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithObjectParam1:objectParam2:), 0);
}

- (void)testThatVerifyFailsForNonMatchingObjectArguments {
    // when
    [object voidMethodCallWithObjectParam1:@"World" objectParam2:@"Hello"];
    
    // then
    AssertFails({
        verify [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithObjectParam1:objectParam2:), 0);
}

- (void)testThatVerifySucceedsForMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithIntParam1:2 intParam2:45];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithIntParam1:intParam2:), 0);
}

- (void)testThatVerifyFailsForNonMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertFails({
        verify [object voidMethodCallWithIntParam1:0 intParam2:45];
    });
    
    AssertNumberOfInvocations(object, 1);
    AssertSelectorCalledAtIndex(object, @selector(voidMethodCallWithIntParam1:intParam2:), 0);
}


#pragma mark - Test Verify with Argument Matchers

- (void)testThatVerifySucceedsForAnyIntegerWithAnyIntMatcher {
    // when
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyIntMatcher {
    // when
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMin intParam2:NSIntegerMax];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
        verify [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
    });
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
    stub [object objectMethodCallWithoutParameters]; soItWill returnValue(@"Hello World");
    
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
    soItWill performBlock(^(NSInvocation *inv) {
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
    stub [object1 objectMethodCallWithoutParameters]; soItWill returnValue(@"First Object");
    stub [object2 objectMethodCallWithoutParameters]; soItWill returnValue(@"Second Object");
    stub [object3 objectMethodCallWithoutParameters]; soItWill performBlock(^(NSInvocation *inv) {
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
    soItWill performBlock(^(NSInvocation *inv) {
        marker = @"called";
    });
    andItWill returnValue(@20);
    
    // when
    stub [object objectMethodCallWithoutParameters]; soItWill returnValue(@30);
    
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
    soItWill returnValue(@10);
    
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
    soItWill performBlock(^(NSInvocation *inv) { [self description]; });
    andItWill returnValue(10);
    
    // then
    STAssertEquals((int)[array count], (int)10, @"[array count] stub does not work");
}


#pragma mark - Test Stubbing with Argument Matchers

- (void)testThatStubMatchesCallForSimpleIntegersWithAnyIntMatcher {
    // when
    __block BOOL methodMatched = NO;
    stub [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; soItWill performBlock(^(NSInvocation *inv) {
        methodMatched = YES;
    });
    
    // then
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    STAssertTrue(methodMatched, @"Method was not matched");
}

- (void)testThatStubMatchesCallsForEdgeCasesWithAnyIntMatcher {
    // when
    __block int invocationCount = 0;
    stub [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; soItWill performBlock(^(NSInvocation *inv) {
        invocationCount++;
    });
    
    // then
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMax intParam2:NSIntegerMin];
    STAssertEquals(invocationCount, 2, @"Not all egde cases match");
}

@end
