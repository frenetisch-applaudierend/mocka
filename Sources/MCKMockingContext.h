//
//  MCKMockingContext.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKVerificationHandler;
@protocol MCKStubAction;
@protocol MCKArgumentMatcher;
@protocol MCKVerifier;

@class MCKInvocationStubber;
@class MCKStub;
@class MCKArgumentMatcherRecorder;
@class MCKFailureHandler;


typedef enum {
    MCKContextModeRecording,
    MCKContextModeStubbing,
    MCKContextModeVerifying,
} MCKContextMode;


@interface MCKMockingContext : NSObject


#pragma mark - Getting a Context

+ (instancetype)contextForTestCase:(id)testCase;
+ (instancetype)currentContext;


#pragma mark - Initialization

- (instancetype)initWithTestCase:(id)testCase;


#pragma mark - Update Location Data

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber;


#pragma mark - Handling Failures

@property (nonatomic, strong) MCKFailureHandler *failureHandler;

- (void)failWithReason:(NSString *)reason, ... NS_FORMAT_FUNCTION(1,2);


#pragma mark - Handling Invocations

@property (nonatomic, readonly) MCKContextMode mode;

- (void)updateContextMode:(MCKContextMode)newMode;
- (void)handleInvocation:(NSInvocation *)invocation;


#pragma mark - Recording

@property (nonatomic, readonly) NSArray *recordedInvocations;


#pragma mark - Stubbing

@property (nonatomic, readonly) MCKInvocationStubber *invocationStubber;

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation;
- (void)addStubAction:(id<MCKStubAction>)action;


#pragma mark - Verifying

@property (nonatomic, strong) id<MCKVerifier> verifier;
@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;


#pragma mark - Argument Matchers

@property (nonatomic, readonly) MCKArgumentMatcherRecorder *argumentMatcherRecorder;

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher;
- (UInt8)pushObjectArgumentMatcher:(id<MCKArgumentMatcher>)matcher;

@end
