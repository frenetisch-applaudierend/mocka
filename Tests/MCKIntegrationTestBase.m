//
//  MCKIntegrationTestBase.m
//  mocka
//
//  Created by Markus Gasser on 2.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKIntegrationTestBase.h"


@implementation MCKIntegrationTestBase

#pragma mark - Abstract Test Support

+ (NSArray *)testInvocations {
    // make sure we don't execute the test base
    if (self == [MCKIntegrationTestBase class]) {
        return @[];
    } else {
        return [super testInvocations];
    }
}


#pragma mark - Setup and Teardown

- (void)setUp {
    [super setUp];
    
    MCKMockingContext *context = [MCKMockingContext currentContext];
    [context setFailureHandler:[[MCKExceptionFailureHandler alloc] init]];
    
    _testObject = [self createTestObject];
    XCTAssertNotNil(_testObject, @"Test object cannot be nil");
}

- (TestObject *)createTestObject {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Override this method" userInfo:nil];
}

- (CategoriesTestMockedClass *)createCategoriesTestObject {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Override this method" userInfo:nil];
}


#pragma mark - Test Simple Verify

- (void)testThatVerifySucceedsForSimpleCall {
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatVerifyFailsForMissingMethodCall {
    // then
    AssertFails({
        verifyCall ([self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatVerifySucceedsForTwoCallsAndTwoVerifies {
    // when
    [self.testObject voidMethodCallWithoutParameters];
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithoutParameters]);
    });
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatVerifyFailsIfAppliedTwiceToOneCall {
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithoutParameters]);
    });
    AssertFails({
        verifyCall ([self.testObject voidMethodCallWithoutParameters]);
    });
}


#pragma mark - Test Verify with Handlers

- (void)testThatVerifyNeverFailsWhenCallWasMade {
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verifyCall (never [self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatVerifyNeverSucceedsWhenNoCallWasMade {
    AssertDoesNotFail({
        verifyCall (never [self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatExactlyOneSucceedsWhenOneCallWasMade {
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        verifyCall (exactly(1) [self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatExactlyOneFailsWhenNoCallWasMade {
    AssertFails({
        verifyCall (exactly(1) [self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatExactlyOneFailsWhenMultipleCallsWereMade {
    // when
    [self.testObject voidMethodCallWithoutParameters];
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        verifyCall (exactly(1) [self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatAfterVerifyContextSwitchesToRecordingMode {
    // given
    [self.testObject voidMethodCallWithoutParameters];
    verifyCall ([self.testObject voidMethodCallWithoutParameters]);
    
    // then
    AssertDoesNotFail({
        [self.testObject voidMethodCallWithoutParameters];
    });
}


#pragma mark - Test Verify with Arguments

- (void)testThatVerifySucceedsForMatchingObjectArguments {
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"]);
    });
}

- (void)testThatVerifyFailsForNonMatchingObjectArguments {
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"World" objectParam2:@"Hello"];
    
    // then
    AssertFails({
        verifyCall ([self.testObject voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"]);
    });
}

- (void)testThatVerifySucceedsForMatchingPrimitiveArguments {
    // when
    [self.testObject voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithIntParam1:2 intParam2:45]);
    });
}

- (void)testThatVerifyFailsForNonMatchingPrimitiveArguments {
    // when
    [self.testObject voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertFails({
        verifyCall ([self.testObject voidMethodCallWithIntParam1:0 intParam2:45]);
    });
}


#pragma mark - Test Verify with Argument Matchers

- (void)testThatVerifySucceedsForAnyIntegerWithAnyIntMatcher {
    // when
    [self.testObject voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]);
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyIntMatcher {
    // when
    [self.testObject voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [self.testObject voidMethodCallWithIntParam1:NSIntegerMin intParam2:NSIntegerMax];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]);
        verifyCall ([self.testObject voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]);
    });
}

- (void)testThatVerifySucceedsForAnyObjectWithAnyObjMatcher {
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Foo" objectParam2:@42];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithObjectParam1:anyObject() objectParam2:anyObject()]);
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyObjMatcher {
    // when
    [self.testObject voidMethodCallWithObjectParam1:nil objectParam2:[NSNull null]];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithObjectParam1:anyObject() objectParam2:anyObject()]);
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectParameters {
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Foo" objectParam2:@"Bar"];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithObjectParam1:anyObject() objectParam2:@"Bar"]);
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectAndPrimitiveParameters {
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Foo" intParam2:20];
    
    // then
    AssertDoesNotFail({
        verifyCall ([self.testObject voidMethodCallWithObjectParam1:@"Foo" intParam2:anyInt()]);
    });
}

#pragma mark - Test Stubbing

- (void)testThatUnstubbedMethodsReturnDefaultValues {
    expect([self.testObject objectMethodCallWithoutParameters]).to.equal(nil);
    expect([self.testObject intMethodCallWithoutParameters]).to.equal(0);
    expect([self.testObject intPointerMethodCallWithoutParameters]).to.equal(NULL);
    expect(NSEqualRanges(NSMakeRange(0, 0), [self.testObject rangeMethodCallWithoutParameters])).to.beTruthy();
}

- (void)testThatStubbedReturnValueIsReturned {
    // given
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        return @"Hello World";
    };
    
    // when
    id result = [self.testObject objectMethodCallWithoutParameters];
    
    // then
    expect(result).to.equal(@"Hello World");
}

- (void)testMultipleStubActions {
    // given
    __block BOOL called = YES;
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        called = YES;
        return @20;
    };
    
    // when
    id returnValue = [self.testObject objectMethodCallWithoutParameters];
    
    // then
    expect(called).to.beTruthy();
    expect(returnValue).to.equal(@20);
}

- (void)testThatSubsequentStubbingsDontInterfere {
    // given
    TestObject *object1 = [self createTestObject];
    TestObject *object2 = [self createTestObject];
    TestObject *object3 = [self createTestObject];
    TestObject *object4 = [self createTestObject];
    __block NSString *marker = nil;
    
    // when
    stub ([object1 objectMethodCallWithoutParameters]) with { return @"First Object"; };
    stub ([object2 objectMethodCallWithoutParameters]) with { return @"Second Object"; };
    stub ([object3 objectMethodCallWithoutParameters]) with {
        marker = @"Third Object";
        return nil;
    };
    
    [object4 objectMethodCallWithoutParameters];
    
    // then
    expect([object1 objectMethodCallWithoutParameters]).to.equal(@"First Object");
    expect(marker).to.beNil();
    
    expect([object2 objectMethodCallWithoutParameters]).to.equal(@"Second Object");
    expect(marker).to.beNil();
    
    expect([object3 objectMethodCallWithoutParameters]).to.beNil();
    expect(marker).to.equal(@"Third Object");
    
    expect([object4 objectMethodCallWithoutParameters]).to.beNil();
    expect(marker).to.equal(@"Third Object");
    // non-stubbed call was suddenly stubbed otherwise
}

- (void)testThatLaterStubbingsComplementOlderStubbingsOfSameInvocation {
    // given
    __block BOOL firstWasCalled = NO;
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        firstWasCalled = YES;
        return @"First";
    };
    
    __block BOOL secondWasCalled = NO;
    stub ([self.testObject objectMethodCallWithoutParameters]) with {
        secondWasCalled = YES;
        return @"Second";
    };
    
    // when
    id returnValue = [self.testObject objectMethodCallWithoutParameters];
    
    // then
    expect(firstWasCalled).to.beTruthy();
    expect(secondWasCalled).to.beTruthy();
    expect(returnValue).to.equal(@"Second");
}

- (void)testThatMultipleStubbingsCanBeCombined {
    // given
    TestObject *object1 = [self createTestObject];
    TestObject *object2 = [self createTestObject];
    
    // when
    stub ({
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
    stub ([self.testObject objectMethodCallWithoutParameters]) with (TestObject *self, SEL _cmd) {
        [self description];
        return @10;
    };
    
    // then
    expect([self.testObject objectMethodCallWithoutParameters]).to.equal(@10);
}


#pragma mark - Test Stubbing with Argument Matchers

- (void)testThatStubMatchesCallForSimpleIntegersWithAnyIntMatcher {
    // given
    __block BOOL methodMatched = NO;
    stub ([self.testObject voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]) with {
        methodMatched = YES;
    };
    
    // when
    [self.testObject voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    expect(methodMatched).to.beTruthy();
}

- (void)testThatStubMatchesCallsForEdgeCasesWithAnyIntMatcher {
    // given
    __block int invocationCount = 0;
    stub ([self.testObject voidMethodCallWithIntParam1:anyInt() intParam2:anyInt()]) with {
        invocationCount++;
    };
    
    // when
    [self.testObject voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [self.testObject voidMethodCallWithIntParam1:NSIntegerMax intParam2:NSIntegerMin];
    
    // then
    expect(invocationCount).to.equal(2);
}

- (void)testThatCallingStubbedOutParameterCallWithNullWorks {
    // given
    stub ([self.testObject boolMethodCallWithError:anyObjectPointer()]) with {
        return NO;
    };
    
    // if it crashes hard here then the test has failed (a EXC_BAD_ACCESS is more likely than an exception)
    expect(^{ [self.testObject boolMethodCallWithError:NULL]; }).notTo.raiseAny();
}


#pragma mark - Test Stubbing and Verifying of Category Methods

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClass {
    // given
    CategoriesTestMockedClass *mock = [self createCategoriesTestObject];
    
    __block BOOL called = NO;
    stub ([mock categoryMethodInMockedClass]) with {
        called = YES;
    };
    
    // when
    [mock categoryMethodInMockedClass];
    
    // then
    expect(called).to.beTruthy();
    verifyCall ([mock categoryMethodInMockedClass]);
}

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClassSuperclass {
    // given
    CategoriesTestMockedClass *mock = [self createCategoriesTestObject];
    
    __block BOOL called = NO;
    stub ([mock categoryMethodInMockedClassSuperclass]) with {
        called = YES;
    };
    
    // when
    [mock categoryMethodInMockedClassSuperclass];
    
    // then
    expect(called).to.beTruthy();
    verifyCall ([mock categoryMethodInMockedClassSuperclass]);
}

@end
