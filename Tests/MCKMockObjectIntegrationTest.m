//
//  RGClassMockTest.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#define EXP_SHORTHAND
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

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
        verifyCall [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyFailsForMissingMethodCall {
    // then
    AssertFails({
        verifyCall [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifySucceedsForTwoCallsAndTwoVerifies {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyFailsIfAppliedTwiceToOneCall {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithoutParameters];
    });
    AssertFails({
        verifyCall [object voidMethodCallWithoutParameters];
    });
}


#pragma mark - Test Verify with Handlers

- (void)testThatVerifyNeverFailsWhenCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verifyCall never [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatVerifyNeverSucceedsWhenNoCallWasMade {
    AssertDoesNotFail({
        verifyCall never [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatExactlyOneSucceedsWhenOneCallWasMade {
    // when
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall exactly(1) [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatExactlyOneFailsWhenNoCallWasMade {
    AssertFails({
        verifyCall exactly(1) [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatExactlyOneFailsWhenMultipleCallsWereMade {
    // when
    [object voidMethodCallWithoutParameters];
    [object voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verifyCall exactly(1) [object voidMethodCallWithoutParameters];
    });
}

- (void)testThatAfterVerifyContextSwitchesToRecordingMode {
    // given
    [object voidMethodCallWithoutParameters];
    verifyCall [object voidMethodCallWithoutParameters];
    
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
        verifyCall [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
}

- (void)testThatVerifyFailsForNonMatchingObjectArguments {
    // when
    [object voidMethodCallWithObjectParam1:@"World" objectParam2:@"Hello"];
    
    // then
    AssertFails({
        verifyCall [object voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    });
}

- (void)testThatVerifySucceedsForMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithIntParam1:2 intParam2:45];
    });
}

- (void)testThatVerifyFailsForNonMatchingPrimitiveArguments {
    // when
    [object voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertFails({
        verifyCall [object voidMethodCallWithIntParam1:0 intParam2:45];
    });
}


#pragma mark - Test Verify with Argument Matchers

- (void)testThatVerifySucceedsForAnyIntegerWithAnyIntMatcher {
    // when
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyIntMatcher {
    // when
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMin intParam2:NSIntegerMax];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
        verifyCall [object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()];
    });
}

- (void)testThatVerifySucceedsForAnyObjectWithAnyObjMatcher {
    // when
    [object voidMethodCallWithObjectParam1:@"Foo" objectParam2:@42];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithObjectParam1:anyObject() objectParam2:anyObject()];
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyObjMatcher {
    // when
    [object voidMethodCallWithObjectParam1:nil objectParam2:[NSNull null]];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithObjectParam1:anyObject() objectParam2:anyObject()];
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectParameters {
    // when
    [object voidMethodCallWithObjectParam1:@"Foo" objectParam2:@"Bar"];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithObjectParam1:anyObject() objectParam2:@"Bar"];
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectAndPrimitiveParameters {
    // when
    [object voidMethodCallWithObjectParam1:@"Foo" intParam2:20];
    
    // then
    AssertDoesNotFail({
        verifyCall [object voidMethodCallWithObjectParam1:@"Foo" intParam2:anyInt()];
    });
}


#pragma mark - Test Stubbing

- (void)testThatUnstubbedMethodsReturnDefaultValues {
    expect([object objectMethodCallWithoutParameters]).to.equal(nil);
    expect([object intMethodCallWithoutParameters]).to.equal(0);
    expect([object intPointerMethodCallWithoutParameters]).to.equal(NULL);
    expect(NSEqualRanges(NSMakeRange(0, 0), [object rangeMethodCallWithoutParameters])).to.beTruthy();
}

- (void)testThatStubbedReturnValueIsReturned {
    // given
    stubCall ([object objectMethodCallWithoutParameters]) with {
        return @"Hello World";
    };
    
    // when
    id result = [object objectMethodCallWithoutParameters];
    
    // then
    XCTAssertEqualObjects(result, @"Hello World", @"Wrong object value returned");
}

- (void)testMultipleStubActions {
    // given
    __block BOOL called = YES;
    stubCall ([object objectMethodCallWithoutParameters]) with {
        called = YES;
        return @20;
    };
    
    // when
    id returnValue = [object objectMethodCallWithoutParameters];
    
    // then
    expect(called).to.beTruthy();
    expect(returnValue).to.equal(@20);
}

- (void)testThatSubsequentStubbingsDontInterfere {
    // given
    TestObject *object1 = mock([TestObject class]);
    TestObject *object2 = mock([TestObject class]);
    TestObject *object3 = mock([TestObject class]);
    TestObject *object4 = mock([TestObject class]);
    __block NSString *marker = nil;
    
    // when
    stubCall ([object1 objectMethodCallWithoutParameters]) with { return @"First Object"; };
    stubCall ([object2 objectMethodCallWithoutParameters]) with { return @"Second Object"; };
    stubCall ([object3 objectMethodCallWithoutParameters]) with {
        marker = @"Third Object";
        return nil;
    };
    
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
    __block BOOL firstWasCalled = NO;
    stubCall ([object objectMethodCallWithoutParameters]) with {
        firstWasCalled = YES;
        return @"First";
    };
    
    __block BOOL secondWasCalled = NO;
    stubCall ([object objectMethodCallWithoutParameters]) with {
        secondWasCalled = YES;
        return @"Second";
    };
    
    // when
    id returnValue = [object objectMethodCallWithoutParameters];
    
    // then
    expect(firstWasCalled).to.beTruthy();
    expect(secondWasCalled).to.beTruthy();
    expect(returnValue).to.equal(@"Second");
}

- (void)testThatMultipleStubbingsCanBeCombined {
    // given
    TestObject *object1 = mock([TestObject class]);
    TestObject *object2 = mock([TestObject class]);
    
    // when
    stubCalls ({
        [object1 objectMethodCallWithoutParameters];
        [object2 objectMethodCallWithoutParameters];
    }) with {
        return @10;
    };
    
    // then
    expect([object1 objectMethodCallWithoutParameters]).to.equal(@10);
    expect([object2 objectMethodCallWithoutParameters]).to.equal(@10);
}

- (void)testStubbingWithSelfAndCmd {
    // given
    NSMutableArray *array = mock([NSMutableArray class]);
    
    stubCall ([array count]) with (NSArray *self, SEL _cmd) {
        [self description];
        return 10;
    };
    
    // then
    expect([array count]).to.equal(10);
}


#pragma mark - Test Stubbing with Argument Matchers

- (void)testThatStubMatchesCallForSimpleIntegersWithAnyIntMatcher {
    // given
    __block BOOL methodMatched = NO;
    stubCall ([object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]) with {
        methodMatched = YES;
    };
    
    // when
    [object voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    expect(methodMatched).to.beTruthy();
}

- (void)testThatStubMatchesCallsForEdgeCasesWithAnyIntMatcher {
    // given
    __block int invocationCount = 0;
    stubCall ([object voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]) with {
        invocationCount++;
    };
    
    // when
    [object voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [object voidMethodCallWithIntParam1:NSIntegerMax intParam2:NSIntegerMin];
    
    // then
    expect(invocationCount).to.equal(2);
}

- (void)testThatCallingStubbedOutParameterCallWithNullWorks {
    // given
    stubCall ([object boolMethodCallWithError:anyObjectPointer(__autoreleasing)]) with {
        return NO;
    };
    
    // if it crashes hard here then the test has failed (a EXC_BAD_ACCESS is more likely than an exception)
    expect(^{ [object boolMethodCallWithError:NULL]; }).notTo.raiseAny();
}


#pragma mark - Test Stubbing and Verifying of Category Methods

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClass {
    // given
    CategoriesTestMockedClass *mock = mockForClass(CategoriesTestMockedClass);
    
    __block BOOL called = NO;
    stubCall ([mock categoryMethodInMockedClass]) with {
        called = YES;
    };
    
    // when
    [mock categoryMethodInMockedClass];
    
    // then
    expect(called).to.beTruthy();
    verifyCall [mock categoryMethodInMockedClass];
}

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClassSuperclass {
    // given
    CategoriesTestMockedClass *mock = mockForClass(CategoriesTestMockedClass);
    
    __block BOOL called = NO;
    stubCall ([mock categoryMethodInMockedClassSuperclass]) with {
        called = YES;
    };
    
    // when
    [mock categoryMethodInMockedClassSuperclass];
    
    // then
    expect(called).to.beTruthy();
    verifyCall [mock categoryMethodInMockedClassSuperclass];
}

@end
