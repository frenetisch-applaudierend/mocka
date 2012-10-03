//
//  RGMockSpyTest.m
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MockTestObject.h"
#import "FakeMockingContext.h"
#import "RGMockSpy.h"


@interface MockTestObjectSubclass : MockTestObject
@end

@implementation MockTestObjectSubclass
- (int)intMethodCallWithoutParameters { return ([super intMethodCallWithoutParameters] * 2); }
@end

@interface MockTestObject (RGMockSpyTest)
- (int)spySpecialMethod;
@end
@implementation MockTestObject (RGMockSpyTest)
- (int)spySpecialMethod { return 666; }
@end


#pragma mark -
@interface RGMockSpyTest : SenTestCase
@end

@implementation RGMockSpyTest {
    MockTestObject     *spy;
    FakeMockingContext *context;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    context = [FakeMockingContext fakeContext];
    spy = mck_createSpyForObject([[MockTestObject alloc] init], context);
}


#pragma mark - Test Spy Creation and basic characteristics

- (void)testThatCreateSpyTurnsObjectIntoSpy {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    
    // when
    mck_createSpyForObject(object, nil);
    
    // then
    STAssertTrue(mck_objectIsSpy(object), @"Object is not turned into spy");
}

- (void)testThatCreateSpyReturnsPassedObject {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    
    // when
    id objectSpy = mck_createSpyForObject(object, nil);
    
    // then
    STAssertTrue(object == objectSpy, @"A different object than the passed object was returned");
}

- (void)testThatSpyStillReportsPreviousClassIfAskedViaClassMethod {
    // given
    MockTestObject *object = [[MockTestObject alloc] init];
    
    // when
    mck_createSpyForObject(object, nil);
    
    // then
    STAssertEqualObjects([object class], [MockTestObject class], @"Original class was not retained");
}


#pragma mark - Test Forwarding Invocations to the Context

- (void)testThatSpyForwardsInvocationToContext {
    // when
    [spy voidMethodCallWithoutParameters];
    [spy intMethodCallWithoutParameters]; // check two invocations because the implementation does some swizzling when calling. ensure all went ok
    
    // then
    STAssertEquals([context.handledInvocations count], (NSUInteger)2, @"Wrong number of handled invocations");
    STAssertTrue([context.handledInvocations[0] target] == spy, @"Wrong target of handled invocation");
    STAssertTrue([context.handledInvocations[0] selector] == @selector(voidMethodCallWithoutParameters), @"Wrong selector of handled invocation");
    STAssertTrue([context.handledInvocations[1] target] == spy, @"Wrong target of handled invocation");
    STAssertTrue([context.handledInvocations[1] selector] == @selector(intMethodCallWithoutParameters), @"Wrong selector of handled invocation");
}


#pragma mark - Test Calling the original implementation

- (void)testThatSpyExecutesExistingMethodIfInRecordingMode {
    // given
    context.mode = RGMockContextModeRecording;
    
    // when
    [spy voidMethodCallWithoutParameters];
    [spy intMethodCallWithoutParameters]; // check two invocations because the implementation does some swizzling when calling. ensure all went ok
    
    // then
    STAssertEquals([MockTestObjectCalledSelectors(spy) count], (NSUInteger)2, @"Method was not called or too many methods called");
    STAssertEqualObjects(MockTestObjectCalledSelectors(spy)[0], NSStringFromSelector(@selector(voidMethodCallWithoutParameters)), @"Original Method was not called");
    STAssertEqualObjects(MockTestObjectCalledSelectors(spy)[1], NSStringFromSelector(@selector(intMethodCallWithoutParameters)), @"Original Method was not called");
}

- (void)testThatSpyReturnsNormalReturnValueIfCalledInRecordingMode {
    // given
    context.mode = RGMockContextModeRecording;
    
    // when
    int returnValue1 = [spy intMethodCallWithoutParameters];
    int returnValue2 = [spy intMethodCallWithoutParameters]; // check two invocations because the implementation does some swizzling when calling. ensure all went ok
    
    // then
    STAssertEquals(returnValue1, 150, @"Return value was incorrect");
    STAssertEquals(returnValue2, 150, @"Return value was incorrect");
}

- (void)testThatSpyDoesNotExecuteExistingMethodIfInVerificationMode {
    // given
    context.mode = RGMockContextModeVerifying;
    
    // when
    [spy voidMethodCallWithoutParameters];
    
    // then
    STAssertEquals([MockTestObjectCalledSelectors(spy) count], (NSUInteger)0, @"Method was called");
}

- (void)testThatSpyDoesNotExecuteExistingMethodIfInStubbingMode {
    // given
    context.mode = RGMockContextModeStubbing;
    
    // when
    [spy voidMethodCallWithoutParameters];
    
    // then
    STAssertEquals([MockTestObjectCalledSelectors(spy) count], (NSUInteger)0, @"Method was called");
}

- (void)testThatSpyDoesNotExecuteExistingMethodInRecordingModeIfStubExists {
    // given
    context.mode = RGMockContextModeRecording;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:"]];
    invocation.selector = @selector(voidMethodCallWithoutParameters);
    invocation.target = spy;
    [context createStubbingForInvocation:invocation];
    
    // when
    [spy voidMethodCallWithoutParameters];
    
    // then
    STAssertEquals([MockTestObjectCalledSelectors(spy) count], (NSUInteger)0, @"Method was called");
}

- (void)testThatSpyCallsImplementationOfMostRecentOverride {
    // given
    MockTestObjectSubclass *refObject = [[MockTestObjectSubclass alloc] init];
    MockTestObjectSubclass *subclassSpy = mck_createSpyForObject([[MockTestObjectSubclass alloc] init], context);
    context.mode = RGMockContextModeRecording;
    
    // when
    int returnValue = [subclassSpy intMethodCallWithoutParameters];
    
    // then
    STAssertEquals(returnValue, [refObject intMethodCallWithoutParameters], @"Return value was incorrect");
}

#pragma mark - Test Spying in Special Cases

- (void)testThatSpyMocksMethodsInCategories {
    // given
    MockTestObject *refObject = [[MockTestObject alloc] init];
    context.mode = RGMockContextModeRecording;
    
    // when
    int returnValue = [spy spySpecialMethod];
    
    // then
    STAssertEquals(returnValue, [refObject spySpecialMethod], @"Method in category not spied");
}

@end
