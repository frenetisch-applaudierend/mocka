//
//  RGClassMockTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Mocka.h"

#import "TestExceptionUtils.h"
#import "TestObject.h"
#import "CategoriesTestClasses.h"


#pragma mark - Functional Test for mocking a single Class

@interface MCKMockObjectIntegrationTest : XCTestCase
@end

@implementation MCKMockObjectIntegrationTest {
    TestObject *object;
}


#pragma mark - Setup

- (void)setUp {
    [super setUp];
    object = mock([TestObject class]);
    [[MCKMockingContext currentContext] setFailureHandler:[[MCKExceptionFailureHandler alloc] init]];
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


#pragma mark - Test Verify with Handlers

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

- (void)testThatAfterVerifyContextSwitchesToRecordingMode {
    // given
    [object voidMethodCallWithoutParameters];
    verify [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        [object voidMethodCallWithoutParameters];
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

- (void)testThatVerifySucceedsForAnyObjectWithAnyObjMatcher {
    // when
    [object voidMethodCallWithObjectParam1:@"Foo" objectParam2:@42];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithObjectParam1:anyObject() objectParam2:anyObject()];
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyObjMatcher {
    // when
    [object voidMethodCallWithObjectParam1:nil objectParam2:[NSNull null]];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithObjectParam1:anyObject() objectParam2:anyObject()];
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectParameters {
    // when
    [object voidMethodCallWithObjectParam1:@"Foo" objectParam2:@"Bar"];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithObjectParam1:anyObject() objectParam2:@"Bar"];
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectAndPrimitiveParameters {
    // when
    [object voidMethodCallWithObjectParam1:@"Foo" intParam2:20];
    
    // then
    AssertDoesNotFail({
        verify [object voidMethodCallWithObjectParam1:@"Foo" intParam2:anyInt()];
    });
}


#pragma mark - Test Stubbing

- (void)testThatUnstubbedMethodsReturnDefaultValues {
    XCTAssertNil([object objectMethodCallWithoutParameters], @"Should return nil for unstubbed object return");
    XCTAssertEqual([object intMethodCallWithoutParameters], (int)0, @"Should return 0 for unstubbed int return");
    XCTAssertEqual([object intPointerMethodCallWithoutParameters], (int*)NULL, @"Should return NULL for unstubbed pointer return");
    XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 0), [object rangeMethodCallWithoutParameters]), @"Should return uninitialized value for unstubbed range");
}

- (void)testThatStubbedReturnValueIsReturned {
    // given
    whenCalling [object objectMethodCallWithoutParameters]; thenDo returnValue(@"Hello World");
    
    // when
    id result = [object objectMethodCallWithoutParameters];
    
    // then
    XCTAssertEqualObjects(result, @"Hello World", @"Wrong object value returned");
}

- (void)testMultipleStubActions {
    // given
    __block NSString *marker = nil;
    whenCalling [object objectMethodCallWithoutParameters];
    thenDo performBlock(^(NSInvocation *inv) {
        marker = @"called";
    });
    andDo returnValue(@20);
    
    // then
    XCTAssertEqualObjects([object objectMethodCallWithoutParameters], @20, @"Wrong return value");
    XCTAssertEqualObjects(marker, @"called", @"Marker was not set or wrongly set");
}

- (void)testThatSubsequentStubbingsDontInterfere {
    // given
    TestObject *object1 = mock([TestObject class]);
    TestObject *object2 = mock([TestObject class]);
    TestObject *object3 = mock([TestObject class]);
    TestObject *object4 = mock([TestObject class]);
    __block NSString *marker = nil;
    
    // when
    whenCalling [object1 objectMethodCallWithoutParameters]; thenDo returnValue(@"First Object");
    whenCalling [object2 objectMethodCallWithoutParameters]; thenDo returnValue(@"Second Object");
    whenCalling [object3 objectMethodCallWithoutParameters]; thenDo performBlock(^(NSInvocation *inv) {
        marker = @"Third Object";
    });
    
    [object4 objectMethodCallWithoutParameters];
    
    
    // then
    XCTAssertEqualObjects([object1 objectMethodCallWithoutParameters], @"First Object", @"Wrong return value for object");
    XCTAssertNil(marker, @"Marker was set too early");
    
    XCTAssertEqualObjects([object2 objectMethodCallWithoutParameters], @"Second Object", @"Wrong return value for object");
    XCTAssertNil(marker, @"Marker was set too early");
    
    XCTAssertNil([object3 objectMethodCallWithoutParameters], @"Wrong return value for object");
    XCTAssertEqualObjects(marker, @"Third Object", @"Marker was not set or wrongly set");
    
    XCTAssertNil([object4 objectMethodCallWithoutParameters], @"Non-stubbed call was suddenly stubbed");
}

- (void)testThatLaterStubbingsComplementOlderStubbingsOfSameInvocation {
    // given
    __block NSString *marker = nil;
    whenCalling [object objectMethodCallWithoutParameters];
    thenDo performBlock(^(NSInvocation *inv) {
        marker = @"called";
    });
    andDo returnValue(@20);
    
    // when
    whenCalling [object objectMethodCallWithoutParameters]; thenDo returnValue(@30);
    
    // then
    XCTAssertEqualObjects([object objectMethodCallWithoutParameters], @30, @"Wrong return value for object");
    XCTAssertEqualObjects(marker, @"called", @"Marker was not set");
}

- (void)testThatMultipleStubbingsCanBeCombined {
    // given
    TestObject *object1 = mock([TestObject class]);
    TestObject *object2 = mock([TestObject class]);
    
    // when
    whenCalling {
        [object1 objectMethodCallWithoutParameters];
        [object2 objectMethodCallWithoutParameters];
    };
    thenDo returnValue(@10);
    
    // then
    XCTAssertEqualObjects([object1 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
    XCTAssertEqualObjects([object2 objectMethodCallWithoutParameters], @10, @"Wrong return value for object");
}

- (void)testStubbingArray {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    whenCalling [array count];
    thenDo performBlock(^(NSInvocation *inv) { [self description]; });
    andDo returnValue(10);
    
    // then
    XCTAssertEqual((int)[array count], (int)10, @"[array count] stub does not work");
}


#pragma mark - Test Stubbing with Argument Matchers

- (void)testThatStubMatchesCallForSimpleIntegersWithAnyIntMatcher {
    // when
    __block BOOL methodMatched = NO;
    whenCalling [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; thenDo performBlock(^(NSInvocation *inv) {
        methodMatched = YES;
    });
    
    // then
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    XCTAssertTrue(methodMatched, @"Method was not matched");
}

- (void)testThatStubMatchesCallsForEdgeCasesWithAnyIntMatcher {
    // when
    __block int invocationCount = 0;
    whenCalling [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]; thenDo performBlock(^(NSInvocation *inv) {
        invocationCount++;
    });
    
    // then
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMax intParam2:NSIntegerMin];
    XCTAssertEqual(invocationCount, 2, @"Not all egde cases match");
}

- (void)testThatCallingStubbedOutParameterCallWithNullWorks {
    // given
    whenCalling [object boolMethodCallWithError:anyObjectPointer()] thenDo returnValue(NO);
    
    // if it crashes hard here then the test has failed (a EXC_BAD_ACCESS is more likely than an exception)
    XCTAssertNoThrow([object boolMethodCallWithError:NULL], @"Should not crash");
}


#pragma mark - Test Stubbing and Verifying of Category Methods

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClass {
    // given
    CategoriesTestMockedClass *mock = mockForClass(CategoriesTestMockedClass);
    
    __block BOOL called = NO;
    whenCalling [mock categoryMethodInMockedClass] thenDo performBlock(^(NSInvocation *inv) {
        called = YES;
    });
    
    [mock categoryMethodInMockedClass];
    
    verify [mock categoryMethodInMockedClass];
    XCTAssertTrue(called, @"Should have been called");
}

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClassSuperclass {
    // given
    CategoriesTestMockedClass *mock = mockForClass(CategoriesTestMockedClass);
    
    __block BOOL called = NO;
    whenCalling [mock categoryMethodInMockedClassSuperclass] thenDo performBlock(^(NSInvocation *inv) {
        called = YES;
    });
    
    [mock categoryMethodInMockedClassSuperclass];
    
    verify [mock categoryMethodInMockedClassSuperclass];
    XCTAssertTrue(called, @"Should have been called");
}

@end
