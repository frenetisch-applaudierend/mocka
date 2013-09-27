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
@protocol MCKFailureHandler;
@class MCKMutableInvocationCollection;
@class MCKArgumentMatcherCollection;
@class MCKInvocationStubber;
@class MCKStub;


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


#pragma mark - Context Data

@property (nonatomic, readonly) MCKMutableInvocationCollection *recordedInvocations;
@property (nonatomic, readonly) MCKInvocationStubber *invocationStubber;
@property (nonatomic, readonly) MCKArgumentMatcherCollection *argumentMatchers;

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber;


#pragma mark - Failure Handling

@property (nonatomic, strong) id<MCKFailureHandler> failureHandler;

- (void)failWithReason:(NSString *)reason, ...;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) MCKContextMode mode;

- (void)updateContextMode:(MCKContextMode)newMode;
- (void)handleInvocation:(NSInvocation *)invocation;


#pragma mark - Recording

- (void)recordInvocation:(NSInvocation *)invocation;


#pragma mark - Stubbing

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation;
- (void)addStubAction:(id<MCKStubAction>)action;


#pragma mark - Verifying

@property (nonatomic, strong) id<MCKVerifier> verifier;
@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;


#pragma mark - Argument Matchers

@property (nonatomic, readonly, copy) NSArray *primitiveArgumentMatchers;

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher;

@end
