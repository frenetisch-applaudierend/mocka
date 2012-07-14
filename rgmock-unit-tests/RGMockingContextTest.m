//
//  RGMockingContextTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSInvocation+TestSupport.h"
#import "RGMockingContext.h"
#import "RGMockDefaultVerificationHandler.h"


@interface RGMockingContextTest : SenTestCase
@end


@implementation RGMockingContextTest {
    RGMockingContext *context;
}

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    context = [[RGMockingContext alloc] init];
}


#pragma mark - Test Getting a Context

- (void)testThatGettingTheContextTwiceReturnsSameContext {
    id ctx1 = [RGMockingContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    id ctx2 = [RGMockingContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__];
    STAssertEqualObjects(ctx1, ctx2, @"Not the same context returned");
}

- (void)testThatGettingContextUpdatesFileLocationInformation {
    RGMockingContext *ctx = [RGMockingContext contextForTestCase:self fileName:@"Foo" lineNumber:10];
    STAssertEqualObjects(ctx.fileName, @"Foo", @"File name not updated");
    STAssertEquals(ctx.lineNumber, 10, @"Line number not updated");
    
    ctx = [RGMockingContext contextForTestCase:self fileName:@"Bar" lineNumber:20];
    STAssertEqualObjects(ctx.fileName, @"Bar", @"File name not updated");
    STAssertEquals(ctx.lineNumber, 20, @"Line number not updated");
}


#pragma mark - Test Invocation Recording

- (void)testThatHandlingInvocationInRecordingModeAddsToRecordedInvocations {
    // given
    context.mode = RGMockingContextModeRecording;
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
    context.mode = RGMockingContextModeVerifying;
    
    // then
    STAssertEqualObjects(context.verificationHandler, [RGMockDefaultVerificationHandler defaultHandler], @"Not the expected verificationHanlder set");
}

@end
