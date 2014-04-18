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

+ (NSArray *)testInvocations
{
    // make sure we don't execute the test base
    if (self == [MCKIntegrationTestBase class]) {
        return @[];
    } else {
        return [super testInvocations];
    }
}


#pragma mark - Setup and Teardown

- (void)setUp
{
    MCKMockingContext *context = [MCKMockingContext currentContext];
    [context setFailureHandler:[[MCKExceptionFailureHandler alloc] init]];
    
    _testObject = [self createTestObjectMock];
    XCTAssertNotNil(_testObject, @"Test object cannot be nil");
}

- (TestObject *)createTestObjectMock
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Override this method" userInfo:nil];
}

- (CategoriesTestMockedClass *)createCategoriesTestObject
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Override this method" userInfo:nil];
}


#pragma mark - Test Simple Verify

- (void)testThatVerifySucceedsForSimpleCall
{
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatVerifyFailsForMissingMethodCall
{
    // then
    AssertFails({
        match ([self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatVerifySucceedsForTwoCallsAndTwoVerifies
{
    // when
    [self.testObject voidMethodCallWithoutParameters];
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithoutParameters]);
    });
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithoutParameters]);
    });
}

- (void)testThatVerifyFailsIfAppliedTwiceToOneCall
{
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithoutParameters]);
    });
    AssertFails({
        match ([self.testObject voidMethodCallWithoutParameters]);
    });
}


#pragma mark - Test Verify with Handlers

- (void)testThatVerifyNeverFailsWhenCallWasMade
{
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        match ([self.testObject voidMethodCallWithoutParameters]) never;
    });
}

- (void)testThatVerifyNeverSucceedsWhenNoCallWasMade
{
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithoutParameters]) never;
    });
}

- (void)testThatExactlyOnceSucceedsWhenOneCallWasMade
{
    // when
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithoutParameters]) exactly(once);
    });
}

- (void)testThatExactlyOnceFailsWhenNoCallWasMade
{
    AssertFails({
        match ([self.testObject voidMethodCallWithoutParameters]) exactly(once);
    });
}

- (void)testThatExactlyOnceFailsWhenMultipleCallsWereMade
{
    // when
    [self.testObject voidMethodCallWithoutParameters];
    [self.testObject voidMethodCallWithoutParameters];
    
    // then
    AssertFails({
        match ([self.testObject voidMethodCallWithoutParameters]) exactly(once);
    });
}

- (void)testThatAfterVerifyContextSwitchesToRecordingMode
{
    // given
    [self.testObject voidMethodCallWithoutParameters];
    match ([self.testObject voidMethodCallWithoutParameters]);
    
    // then
    AssertDoesNotFail({
        [self.testObject voidMethodCallWithoutParameters];
    });
}


#pragma mark - Test Verify with Arguments

- (void)testThatVerifySucceedsForMatchingObjectArguments
{
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"]);
    });
}

- (void)testThatVerifyFailsForNonMatchingObjectArguments
{
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"World" objectParam2:@"Hello"];
    
    // then
    AssertFails({
        match ([self.testObject voidMethodCallWithObjectParam1:@"Hello" objectParam2:@"World"]);
    });
}

- (void)testThatVerifySucceedsForMatchingPrimitiveArguments
{
    // when
    [self.testObject voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithIntParam1:2 intParam2:45]);
    });
}

- (void)testThatVerifyFailsForNonMatchingPrimitiveArguments
{
    // when
    [self.testObject voidMethodCallWithIntParam1:2 intParam2:45];
    
    // then
    AssertFails({
        match ([self.testObject voidMethodCallWithIntParam1:0 intParam2:45]);
    });
}


#pragma mark - Test Verify with Argument Matchers

- (void)testThatVerifySucceedsForAnyIntegerWithAnyIntMatcher
{
    // when
    [self.testObject voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithIntParam1:any(NSUInteger) intParam2:any(NSUInteger)]);
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyIntMatcher
{
    // when
    [self.testObject voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [self.testObject voidMethodCallWithIntParam1:NSIntegerMin intParam2:NSIntegerMax];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithIntParam1:any(NSInteger) intParam2:any(NSInteger)]);
        match ([self.testObject voidMethodCallWithIntParam1:any(NSInteger) intParam2:any(NSInteger)]);
    });
}

- (void)testThatVerifySucceedsForAnyObjectWithAnyObjMatcher
{
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Foo" objectParam2:@42];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithObjectParam1:any(id) objectParam2:any(id)]);
    });
}

- (void)testThatVerifySucceedsForEdgeCasesWithAnyObjMatcher
{
    // when
    [self.testObject voidMethodCallWithObjectParam1:nil objectParam2:[NSNull null]];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithObjectParam1:any(id) objectParam2:any(id)]);
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectParameters
{
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Foo" objectParam2:@"Bar"];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithObjectParam1:any(id) objectParam2:@"Bar"]);
    });
}

- (void)testCanMixMatcherAndNonMatcherArgumentsForObjectAndPrimitiveParameters
{
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Foo" intParam2:20];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithObjectParam1:@"Foo" intParam2:any(int)]);
    });
}

- (void)testCanUseBlockArgumentMatcher
{
    // when
    [self.testObject voidMethodCallWithObjectParam1:@"Foo" intParam2:20];
    
    // then
    AssertDoesNotFail({
        match ([self.testObject voidMethodCallWithObjectParam1:argMatching(id, ^BOOL(id candidate) {
            return [candidate isEqualToString:@"Foo"];
        }) intParam2:argMatching(int, ^BOOL(int candidate) {
            return candidate == 20;
        })]);
    });
}


#pragma mark - Test Stubbing

- (void)testMultipleStubActions
{
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

- (void)testThatSubsequentStubbingsDontInterfere
{
    // given
    TestObject *object1 = [self createTestObjectMock];
    TestObject *object2 = [self createTestObjectMock];
    TestObject *object3 = [self createTestObjectMock];
    TestObject *object4 = [self createTestObjectMock];
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

- (void)testThatLaterStubbingsComplementOlderStubbingsOfSameInvocation
{
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

- (void)testStubbingWithSelfAndCmd
{
    // given
    stub ([self.testObject objectMethodCallWithoutParameters]) with (TestObject *self, SEL _cmd) {
        [self description];
        return @10;
    };
    
    // then
    expect([self.testObject objectMethodCallWithoutParameters]).to.equal(@10);
}


#pragma mark - Test Stubbing with Argument Matchers

- (void)testThatStubMatchesCallForSimpleIntegersWithAnyIntMatcher
{
    // given
    __block BOOL methodMatched = NO;
    stub ([self.testObject voidMethodCallWithIntParam1:any(NSInteger) intParam2:any(NSInteger)]) with {
        methodMatched = YES;
    };
    
    // when
    [self.testObject voidMethodCallWithIntParam1:10 intParam2:20];
    
    // then
    expect(methodMatched).to.beTruthy();
}

- (void)testThatStubMatchesCallsForEdgeCasesWithAnyIntMatcher
{
    // given
    __block int invocationCount = 0;
    stub ([self.testObject voidMethodCallWithIntParam1:any(NSInteger) intParam2:any(NSInteger)]) with {
        invocationCount++;
    };
    
    // when
    [self.testObject voidMethodCallWithIntParam1:0 intParam2:NSNotFound];
    [self.testObject voidMethodCallWithIntParam1:NSIntegerMax intParam2:NSIntegerMin];
    
    // then
    expect(invocationCount).to.equal(2);
}

- (void)testThatCallingStubbedOutParameterCallWithNullWorks
{
    // given
    stub ([self.testObject boolMethodCallWithError:any(NSError* __autoreleasing *)]) with {
        return NO;
    };
    
    // if it crashes hard here then the test has failed (a EXC_BAD_ACCESS is more likely than an exception)
    expect(^{ [self.testObject boolMethodCallWithError:NULL]; }).notTo.raiseAny();
}


#pragma mark - Test Stubbing and Verifying of Category Methods

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClass
{
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
    match ([mock categoryMethodInMockedClass]);
}

- (void)testStubbingAndVerifyingOfCategoryMethodOnMockedClassSuperclass
{
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
    match ([mock categoryMethodInMockedClassSuperclass]);
}

@end
