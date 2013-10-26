//
//  MCKSpyTest.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKSpy.h"

#import "TestObject.h"
#import "FakeMockingContext.h"



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
    XCTAssertTrue(mck_objectIsSpy(object), @"Object is not turned into spy");
}

- (void)testThatCreateSpyReturnsPassedObject {
    // given
    TestObject *object = [[TestObject alloc] init];
    
    // when
    id objectSpy = mck_createSpyForObject(object, nil);
    
    // then
    XCTAssertTrue(object == objectSpy, @"A different object than the passed object was returned");
}

- (void)testThatSpyStillReportsPreviousClassIfAskedViaClassMethod {
    // given
    TestObject *object = [[TestObject alloc] init];
    
    // when
    mck_createSpyForObject(object, nil);
    
    // then
    XCTAssertEqualObjects([object class], [TestObject class], @"Original class was not retained");
}


#pragma mark - Test Forwarding Invocations to the Context

- (void)testThatSpyForwardsInvocationToContext {
    // when
    [spy voidMethodCallWithoutParameters];
    [spy intMethodCallWithoutParameters]; // check two invocations because the implementation does some swizzling when calling. ensure all went ok
    
    // then
    XCTAssertEqual([context.handledInvocations count], (NSUInteger)2, @"Wrong number of handled invocations");
    XCTAssertTrue([context.handledInvocations[0] target] == spy, @"Wrong target of handled invocation");
    XCTAssertTrue([context.handledInvocations[0] selector] == @selector(voidMethodCallWithoutParameters), @"Wrong selector of handled invocation");
    XCTAssertTrue([context.handledInvocations[1] target] == spy, @"Wrong target of handled invocation");
    XCTAssertTrue([context.handledInvocations[1] selector] == @selector(intMethodCallWithoutParameters), @"Wrong selector of handled invocation");
}


#pragma mark - Test Calling the original implementation

- (void)testThatSpyExecutesExistingMethodIfInRecordingMode {
    // given
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    [spy voidMethodCallWithoutParameters];
    [spy intMethodCallWithoutParameters]; // check two invocations because the implementation does some swizzling when calling. ensure all went ok
    
    // then
    XCTAssertEqual([TestObjectCalledSelectors(spy) count], (NSUInteger)2, @"Method was not called or too many methods called");
    XCTAssertEqualObjects(TestObjectCalledSelectors(spy)[0], NSStringFromSelector(@selector(voidMethodCallWithoutParameters)), @"Original Method was not called");
    XCTAssertEqualObjects(TestObjectCalledSelectors(spy)[1], NSStringFromSelector(@selector(intMethodCallWithoutParameters)), @"Original Method was not called");
}

- (void)testThatSpyReturnsNormalReturnValueIfCalledInRecordingMode {
    // given
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    int returnValue1 = [spy intMethodCallWithoutParameters];
    int returnValue2 = [spy intMethodCallWithoutParameters]; // check two invocations because the implementation does some swizzling when calling. ensure all went ok
    
    // then
    XCTAssertEqual(returnValue1, 150, @"Return value was incorrect");
    XCTAssertEqual(returnValue2, 150, @"Return value was incorrect");
}

- (void)testThatSpyDoesNotExecuteExistingMethodIfInVerificationMode {
    // given
    [context beginVerificationWithTimeout:0.0];
    
    // when
    @try {
        [spy voidMethodCallWithoutParameters];
    } @catch (NSException *exception) {
        // ignore, it's because verification fails
    }
    
    // then
    XCTAssertEqual([TestObjectCalledSelectors(spy) count], (NSUInteger)0, @"Method was called");
}

- (void)testThatSpyDoesNotExecuteExistingMethodIfInStubbingMode {
    // given
    [context beginStubbing];
    
    // when
    [spy voidMethodCallWithoutParameters];
    
    // then
    XCTAssertEqual([TestObjectCalledSelectors(spy) count], (NSUInteger)0, @"Method was called");
}

- (void)testThatSpyDoesNotExecuteExistingMethodInRecordingModeIfStubExists {
    // given
    [context updateContextMode:MCKContextModeRecording];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    invocation.selector = @selector(voidMethodCallWithoutParameters);
    invocation.target = spy;
    [context stubInvocation:invocation];
    
    // when
    [spy voidMethodCallWithoutParameters];
    
    // then
    XCTAssertEqual([TestObjectCalledSelectors(spy) count], (NSUInteger)0, @"Method was called");
}

- (void)testThatSpyCallsImplementationOfMostRecentOverride {
    // given
    MockTestObjectSubclass *refObject = [[MockTestObjectSubclass alloc] init];
    MockTestObjectSubclass *subclassSpy = mck_createSpyForObject([[MockTestObjectSubclass alloc] init], context);
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    int returnValue = [subclassSpy intMethodCallWithoutParameters];
    
    // then
    XCTAssertEqual(returnValue, [refObject intMethodCallWithoutParameters], @"Return value was incorrect");
}

#pragma mark - Test Spying in Special Cases

- (void)testThatSpyMocksMethodsInCategories {
    // given
    TestObject *refObject = [[TestObject alloc] init];
    [context updateContextMode:MCKContextModeRecording];
    
    // when
    int returnValue = [spy spySpecialMethod];
    
    // then
    XCTAssertEqual(returnValue, [refObject spySpecialMethod], @"Method in category not spied");
}

@end
