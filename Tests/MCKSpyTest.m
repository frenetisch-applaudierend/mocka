//
//  MCKSpyTest.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKSpy.h"
#import "MCKStub.h"
#import "MCKVerification.h"
#import "MCKInvocationVerifier.h"

#import "TestObject.h"
#import "FakeMockingContext.h"
#import "NSInvocation+TestSupport.h"


@interface MockTestObjectSubclass : TestObject
@end

@implementation MockTestObjectSubclass
- (int)intMethodCallWithoutParameters { return ([super intMethodCallWithoutParameters] * 2); }
@end

@interface TestObject (MCKSpyTest)
- (int)spySpecialMethod;
@end

@implementation TestObject (MCKSpyTest)
- (int)spySpecialMethod { return 666; }
@end


#pragma mark -
@interface MCKSpyTest : XCTestCase
@end

@implementation MCKSpyTest {
    TestObject *spy;
    FakeMockingContext *context;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    context = [FakeMockingContext fakeContext];
    spy = mck_createSpyForObject([[TestObject alloc] init], context);
}


#pragma mark - Test Spy Creation and basic characteristics

- (void)testThatCreateSpyTurnsObjectIntoSpy {
    // given
    TestObject *object = [[TestObject alloc] init];
    
    // when
    mck_createSpyForObject(object, nil);
    
    // then
    expect(mck_objectIsSpy(object)).to.beTruthy();
}

- (void)testThatCreateSpyReturnsPassedObject {
    // given
    TestObject *object = [[TestObject alloc] init];
    
    // when
    id objectSpy = mck_createSpyForObject(object, nil);
    
    // then
    expect(objectSpy).to.beIdenticalTo(object);
}

- (void)testThatSpyStillReportsPreviousClassIfAskedViaClassMethod {
    // given
    TestObject *object = [[TestObject alloc] init];
    
    // when
    mck_createSpyForObject(object, nil);
    
    // then
    expect([object class]).to.equal([TestObject class]);
}

- (void)testThatCreateSpyRegistersSpyWithTheMockingContext
{
    // given
    MCKMockingContext *mockingContext = MKTMock([MCKMockingContext class]);
    
    // when
    id spiedObject = mck_createSpyForObject([[TestObject alloc] init], mockingContext);
    
    // then
    [MKTVerify(mockingContext) registerMockObject:spiedObject];
}

- (void)testThatTheSpyDoesNotHaveStrongReferenceToMockingContext
{
    // given
    __strong MCKMockingContext *strongContext = [[MCKMockingContext alloc] init];
    __weak   MCKMockingContext *weakContext = strongContext;
    __strong id spiedObject = mck_createSpyForObject([[TestObject alloc] init], strongContext);
    
    // when
    strongContext = nil; // this should be the last strong reference
    
    // then
    expect(weakContext).to.beNil(); // otherwise there must be another strong reference
    spiedObject = nil;
}


#pragma mark - Test Forwarding Invocations to the Context

- (void)testThatSpyForwardsInvocationToContext {
    // when
    [spy voidMethodCallWithoutParameters]; // check two invocations because the implementation
    [spy intMethodCallWithoutParameters];  // does some temporary method swizzling when calling. ensure all went ok
    
    
    // then
    expect([context.handledInvocations count]).to.equal(2);
    expect([context.handledInvocations[0] target]).to.beIdenticalTo(spy);
    expect([context.handledInvocations[0] selector]).to.equal(@selector(voidMethodCallWithoutParameters));
    expect([context.handledInvocations[1] target]).to.beIdenticalTo(spy);
    expect([context.handledInvocations[1] selector]).to.equal(@selector(intMethodCallWithoutParameters));
}


#pragma mark - Test Calling the original implementation

- (void)testThatSpyExecutesExistingMethodIfInRecordingMode {
    // given
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    [spy voidMethodCallWithoutParameters]; // check two invocations because the implementation
    [spy intMethodCallWithoutParameters];  // does some temporary method swizzling when calling. ensure all went ok
    
    
    // then
    expect(TestObjectCalledSelectors(spy)).to.equal(@[
        NSStringFromSelector(@selector(voidMethodCallWithoutParameters)),
        NSStringFromSelector(@selector(intMethodCallWithoutParameters))
    ]);
}

- (void)testThatSpyReturnsNormalReturnValueIfCalledInRecordingMode {
    // given
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    int returnValue1 = [spy intMethodCallWithoutParameters]; // check two invocations because the implementation
    int returnValue2 = [spy intMethodCallWithoutParameters]; // does some temporary method swizzling when calling.
                                                             // ensure all went ok
    
    // then
    expect(returnValue1).to.equal(150);
    expect(returnValue2).to.equal(150);
}

- (void)testThatSpyDoesNotExecuteExistingMethodIfInVerificationMode {
    // when
    __block BOOL called = NO;
    @try {
        MCKVerification *verification = [[MCKVerification alloc] initWithMockingContext:context location:nil verificationBlock:^{
            [spy voidMethodCallWithoutParameters];
            called = YES;
        }];
        [context.invocationVerifier processVerification:verification];
    } @catch (NSException *exception) {
        // ignore, it's because verification fails
    }
    
    // then
    expect(TestObjectCalledSelectors(spy)).to.beEmpty();
    expect(called).to.beTruthy();
}

- (void)testThatSpyDoesNotExecuteExistingMethodIfInStubbingMode {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    
    // when
    [spy voidMethodCallWithoutParameters];
    
    // then
    expect(TestObjectCalledSelectors(spy)).to.beEmpty();
}

- (void)testThatSpyDoesNotExecuteExistingMethodInRecordingModeIfStubExists {
    // given
    SEL selector = @selector(voidMethodCallWithoutParameters);
    [context stubCalls:^{
        [context handleInvocation:[NSInvocation invocationForTarget:spy selectorAndArguments:selector]];
    }].stubBlock = ^{
        // just having a block is enough
    };
    
    // when
    [spy voidMethodCallWithoutParameters];
    
    // then
    expect(TestObjectCalledSelectors(spy)).to.beEmpty();
}

- (void)testThatSpyCallsImplementationOfMostRecentOverride {
    // given
    MockTestObjectSubclass *reference = [[MockTestObjectSubclass alloc] init];
    MockTestObjectSubclass *subclassSpy = mck_createSpyForObject([[MockTestObjectSubclass alloc] init], context);
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    int returnValue = [subclassSpy intMethodCallWithoutParameters];
    
    // then
    expect(returnValue).to.equal([reference intMethodCallWithoutParameters]);
}


#pragma mark - Test Spying in Special Cases

- (void)testThatSpyMocksMethodsInCategories {
    // given
    TestObject *reference = [[TestObject alloc] init];
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    int returnValue = [spy spySpecialMethod];
    
    // then
    expect(returnValue).to.equal([reference spySpecialMethod]);
}

@end
