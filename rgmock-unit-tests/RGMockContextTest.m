//
//  RGMockingContextTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSInvocation+TestSupport.h"
#import "FakeVerificationHandler.h"
#import "RGMockTestingUtils.h"

#import "RGMockContext.h"
#import "RGMockDefaultVerificationHandler.h"


@interface RGMockContextTest : SenTestCase
@end


@implementation RGMockContextTest {
    RGMockContext *context;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    context = [[RGMockContext alloc] init];
}


#pragma mark - Test Getting a Context

- (void)testThatGettingTheContextTwiceReturnsSameContext {
    id ctx1 = [RGMockContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    id ctx2 = [RGMockContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    STAssertEqualObjects(ctx1, ctx2, @"Not the same context returned");
}

- (void)testThatGettingContextUpdatesFileLocationInformation {
    RGMockContext *ctx = [RGMockContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    STAssertEqualObjects(ctx.fileName, @"Foo", @"File name not updated");
    STAssertEquals(ctx.lineNumber, 10, @"Line number not updated");
    
    ctx = [RGMockContext contextForTestCase:self fileName:@"Bar" lineNumber:20];
    STAssertEqualObjects(ctx.fileName, @"Bar", @"File name not updated");
    STAssertEquals(ctx.lineNumber, 20, @"Line number not updated");
}


#pragma mark - Test Error Reporting

- (void)testThatFailWithReasonCreatesSenTestException {
    RGMockContext *ctx = [RGMockContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    @try {
        [ctx failWithReason:@"Test reason"];
        STFail(@"Should have thrown");
    }
    @catch (NSException *exception) {
        STAssertEqualObjects(exception.name, SenTestFailureException, @"Wrong exception name");
        STAssertEqualObjects(exception.reason, @"Test reason", @"Wrong exception reason");
        STAssertEqualObjects([exception.userInfo objectForKey:SenTestFilenameKey], @"Foo", @"Wrong filename reported");
        STAssertEqualObjects([exception.userInfo objectForKey:SenTestLineNumberKey], @10, @"Wrong line number reported");
    }
}


#pragma mark - Test Invocation Recording

- (void)testThatHandlingInvocationInRecordingModeAddsToRecordedInvocations {
    // given
    [context updateContextMode:RGMockContextModeRecording];
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)];
    
    // when
    [context handleInvocation:invocation];
    
    // then
    STAssertTrue([context.recordedInvocations containsObject:invocation], @"Invocation was not recorded");
}


#pragma mark - Test Invocation Verification

- (void)testThatSettingVerificationModeSetsDefaultVerificationHandler {
    // given
    context.verificationHandler = nil;
    STAssertNil(context.verificationHandler, @"verificationHandler was stil set after setting to nil");
    
    // when
    [context updateContextMode:RGMockContextModeVerifying];
    
    // then
    STAssertEqualObjects(context.verificationHandler, [RGMockDefaultVerificationHandler defaultHandler], @"Not the expected verificationHanlder set");
}

- (void)testThatHandlingInvocationInVerificationModeCallsVerificationHandler {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    
    // when
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    
    // then
    STAssertEquals([(FakeVerificationHandler *)context.verificationHandler numberOfCalls], (NSUInteger)1, @"Number of calls is wrong");
}

- (void)testThatHandlingInvocationInVerificationModeThrowsIfHandlerIsNotSatisfied {
    // given
    [context updateContextMode:RGMockContextModeVerifying];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:NO];
    
    // then
    AssertFails({
        [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    });
}

- (void)testThatHandlingInvocationInVerificationModeRemovesMatchingInvocationsFromRecordedInvocations {
    // given
    [context updateContextMode:RGMockContextModeRecording];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(setUp)]];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(tearDown)]];
    [context handleInvocation:[NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)]]; // record some calls
    STAssertEquals([context.recordedInvocations count], (NSUInteger)3, @"Calls were not recorded");
    
    [context updateContextMode:RGMockContextModeVerifying];
    NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSetWithIndex:0]; [toRemove addIndex:2];
    context.verificationHandler = [FakeVerificationHandler handlerWhichReturns:toRemove isSatisfied:YES];
    
    // when
    [context handleInvocation:nil]; // any invocation is ok, just as long as the handler is called
    
    // then
    STAssertEquals([context.recordedInvocations count], (NSUInteger)1, @"Calls were not removed");
    STAssertEquals([[context.recordedInvocations lastObject] selector], @selector(tearDown), @"Wrong calls were removed");
}

@end
