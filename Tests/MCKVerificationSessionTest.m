//
//  MCKVerificationSessionTest.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKVerificationSession.h"
#import <Mocka/MCKVerificationHandler.h>
#import <Mocka/MCKDefaultVerificationHandler.h>

#import "FakeInvocationPrototype.h"
#import "FakeVerificationHandler.h"
#import "NSInvocation+TestSupport.h"

@interface VerificationSessionDelegate : NSObject <MCKVerificationSessionDelegate>

@property (nonatomic, copy) void(^onFailure)(NSString *reason);
@property (nonatomic, copy) void(^onFinish)(void);

@end


@interface MCKVerificationSessionTest : XCTestCase @end
@implementation MCKVerificationSessionTest {
    MCKVerificationSession *session;
    VerificationSessionDelegate *sessionDelegate;
    NSMutableArray *invocations;
}

#pragma mark - Setup

- (void)setUp {
    sessionDelegate = [[VerificationSessionDelegate alloc] init];
    session = [[MCKVerificationSession alloc] init];
    session.delegate = sessionDelegate;
    
    invocations = [NSMutableArray arrayWithObjects:
                   [NSInvocation voidMethodInvocationForTarget:nil],
                   [NSInvocation voidMethodInvocationForTarget:nil],
                   [NSInvocation voidMethodInvocationForTarget:nil], nil];
}


#pragma mark - Test Initialization

- (void)testThatDefaultHandlerIsSet {
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}


#pragma mark - Test Single Call Mode

- (void)testThatVerifyPassesArgumentsToVerificationHandlerInSingleMode {
    // given
    FakeVerificationHandler *handler = [FakeVerificationHandler handlerWhichSucceeds];
    session.verificationHandler = handler;
    
    // when
    MCKInvocationPrototype *prototype = [FakeInvocationPrototype thatAlwaysMatches];
    [session verifyInvocations:invocations forPrototype:prototype];
    
    // then
    XCTAssertEqualObjects([[handler.calls lastObject] prototype], prototype, @"Wrong prototype passed");
    XCTAssertEqualObjects([[handler.calls lastObject] invocations], invocations, @"Wrong invocations passed");
}

- (void)testThatVerifyNotifiesOnlyFinishAfterSuccessInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    __block BOOL onFinishCalled = NO; sessionDelegate.onFinish = ^{ onFinishCalled = YES; };
    __block BOOL onFailureCalled = NO; sessionDelegate.onFailure = ^(NSString *_){ onFailureCalled = YES; };
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    
    // then
    XCTAssertTrue(onFinishCalled, @"On finish was not called");
    XCTAssertFalse(onFailureCalled, @"On failure was called");
}

- (void)testThatVerifyNotifiesFirstFailureThenFinishAfterFailureInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
    NSMutableArray *calls = [NSMutableArray array];
    sessionDelegate.onFinish = ^{ [calls addObject:@"onFinish"]; };
    sessionDelegate.onFailure = ^(NSString *_){ [calls addObject:@"onFailure"]; };
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype thatAlwaysMatches]];
    
    // then
    XCTAssertEqualObjects(calls, (@[ @"onFailure", @"onFinish" ]), @"Notifications not in correct order");
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterSuccessInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceedsWithMatches:[NSIndexSet indexSetWithIndex:1]];
    NSArray *expectedRemainingInvocations = @[ invocations[0], invocations[2] ];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatVerifyRemovesMatchingInvocationsAfterFailureInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithMatches:[NSIndexSet indexSetWithIndex:1]
                                                                                 reason:nil];
    NSArray *expectedRemainingInvocations = @[ invocations[0], invocations[2] ];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertEqualObjects(invocations, expectedRemainingInvocations, @"Invocations were not removed");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterSuccessInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichSucceeds];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}

- (void)testThatVerifyResetsHandlerToDefaultAfterFailureInSingleMode {
    // given
    session.verificationHandler = [FakeVerificationHandler handlerWhichFailsWithReason:nil];
    
    // when
    [session verifyInvocations:invocations forPrototype:[FakeInvocationPrototype dummy]];
    
    // then
    XCTAssertTrue([session.verificationHandler isKindOfClass:[MCKDefaultVerificationHandler class]], @"Wrong default handler");
}



@end


@implementation VerificationSessionDelegate

- (void)verificationSession:(MCKVerificationSession *)session didFailWithReason:(NSString *)reason {
    if (self.onFailure != nil) {
        self.onFailure(reason);
    }
}

- (void)verificationSessionDidEnd:(MCKVerificationSession *)session {
    if (self.onFinish != nil) {
        self.onFinish();
    }
}

@end
