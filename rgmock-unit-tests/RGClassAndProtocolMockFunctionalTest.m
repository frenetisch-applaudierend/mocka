//
//  RGClassMockTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockTestingUtils.h"
#import "MockTestObject.h"

#import "RGMock.h"


#pragma mark - Functional Test for mocking a single Class

@interface RGClassAndProtocolMockFunctionalTest : SenTestCase
@end

@implementation RGClassAndProtocolMockFunctionalTest {
    MockTestObject *object;
}


#pragma mark - Setup

- (void)setUp {
    [super setUp];
    object = mock([MockTestObject class]);
}


#pragma mark - Test Simple Verify

- (void)testThatVerifySucceedsForSimpleCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyFailsForMissingMethodCall {
    // then
    AssertFails({
        verify [object voidMethodCallWithoutParameters];
    });
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
}


#pragma mark - Test Verify with handlers

- (void)testThatVerifyNeverFailsWhenCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verify never [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyNeverSucceedsWhenNoCallWasMade {
    AssertDoesNotFail({
        verify never [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatExactlyOneSucceedsWhenOneCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verify exactly(1) [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatExactlyOneFailsWhenNoCallWasMade {
    AssertFails({
        verify exactly(1) [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatExactlyOneFailsWhenMultipleCallsWereMade {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verify exactly(1) [object voidMethodCallWithoutParameters];
    });
}


#pragma mark - Test Verify with Arguments

- (void)testThatVerifySucceedsForMatchingObjectArguments {
    // when
    [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
}

- (void)testThatVerifyFailsForNonMatchingObjectArguments {
    // when
    [object voidMethodCallWithObjectParam1:@"World" objectParam2:@"Hello"];
    
    // then
    AssertFails({
        verify [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
}

- (void)testThatVerifySucceedsForMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithIntParam1:2 intParam2:45];
    });
}

- (void)testThatVerifyFailsForNonMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertFails({
        verify [object voidMethodCallWithIntParam1:0 intParam2:45];
    });
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

- (void)testThatUnstubbedMethodsReturnDefaultValues {
    STAssertNil([object objectMethodCallWithoutParameters], @"Should return nil for unstubbed object return");
    STAssertEquals([object intMethodCallWithoutParameters], (int)0, @"Should return 0 for unstubbed int return");
    STAssertEquals([object intPointerMethodCallWithoutParameters], (int*)NULL, @"Should return NULL for unstubbed pointer return");
    STAssertTrue(NSEqualRanges(NSMakeRange(0, 0), [object rangeMethodCallWithoutParameters]), @"Should return uninitialized value for unstubbed range");
}

- (void)testThatStubbedReturnValueIsReturned {
    // given
    stub [object objectMethodCallWithoutParameters]; soThatItWill returnValue(@"Hello World");
    
    // when
    id result = [object objectMethodCallWithoutParameters];
    
    // then
    STAssertEqualObjects(result, @"Hello World", @"Wrong object value returned");
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
}

- (void)testThatSubsequentStubbingsDontInterfere {
    // given
    MockTestObject *object1 = mock([MockTestObject class]);
    MockTestObject *object2 = mock([MockTestObject class]);
    MockTestObject *object3 = mock([MockTestObject class]);
    MockTestObject *object4 = mock([MockTestObject class]);
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
    
    STAssertNil([object4 objectMethodCallWithoutParameters], @"Non-stubbed call was suddenly stubbed");
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
}

- (void)testThatMultipleStubbingsCanBeCombined {
    // given
    MockTestObject *object1 = mock([MockTestObject class]);
    MockTestObject *object2 = mock([MockTestObject class]);
    
    // when
    stub {
        [object1 objectMethodCallWithoutParameters];
        [object2 objectMethodCallWithoutParameters];
    };
    soThatItWill returnValue(@10);
    
    // then
    STAssertEqualObjects([object1 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
    STAssertEqualObjects([object2 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
}

- (void)testStubbingArray {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    stub [array count];
    soThatItWill performBlock(^(NSInvocation *inv) { [self description]; });
    andItWill returnValue(10);
    
    // then
    STAssertEquals((int)[array count], (int)10, @"[array count] stub does not work");
}


#pragma mark - Test Stubbing with Argument Matchers

- (void)testThatStubMatchesCallForSimpleIntegersWithAnyIntMatcher {
    // when
    __block BOOL methodMatched = NO;
    stub [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; soThatItWill performBlock(^(NSInvocation *inv) {
        methodMatched = YES;
    });
    
    // then
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    STAssertTrue(methodMatched, @"Method was not matched");
}

- (void)testThatStubMatchesCallsForEdgeCasesWithAnyIntMatcher {
    // when
    __block int invocationCount = 0;
    stub [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; soThatItWill performBlock(^(NSInvocation *inv) {
        invocationCount++;
    });
    
    // then
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMax intParam2:NSIntegerMin];
    STAssertEquals(invocationCount, 2, @"Not all egde cases match");
}

@end
