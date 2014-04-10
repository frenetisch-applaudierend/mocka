//
//  MCKMockingContext.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKInvocationRecorder;
@class MCKInvocationStubber;
@class MCKInvocationVerifier;
@class MCKArgumentMatcherRecorder;
@protocol MCKFailureHandler;

@class MCKLocation;

@protocol MCKVerificationHandler;
@protocol MCKArgumentMatcher;
@class MCKStub;
@protocol MCKVerificationResultCollector;


typedef enum {
    MCKContextModeRecording,
    MCKContextModeStubbing,
    MCKContextModeVerifying,
} MCKContextMode;


@interface MCKMockingContext : NSObject


#pragma mark - Getting a Context

+ (void)setCurrentContext:(MCKMockingContext *)context;
+ (instancetype)currentContext;


#pragma mark - Initialization

- (instancetype)initWithTestCase:(id)testCase;
- (instancetype)init;


#pragma mark - Core Objects

@property (nonatomic, strong) MCKInvocationRecorder *invocationRecorder;
@property (nonatomic, strong) MCKInvocationStubber *invocationStubber;
@property (nonatomic, strong) MCKInvocationVerifier *invocationVerifier;
@property (nonatomic, strong) MCKArgumentMatcherRecorder *argumentMatcherRecorder;
@property (nonatomic, strong) id<MCKFailureHandler> failureHandler;


#pragma mark - Registering Mocks

- (void)registerMockObject:(id)mockObject;


#pragma mark - File Location Data

@property (nonatomic, copy) MCKLocation *currentLocation;


#pragma mark - Dispatching Invocations

@property (nonatomic, readonly) MCKContextMode mode;

- (void)updateContextMode:(MCKContextMode)newMode;
- (void)handleInvocation:(NSInvocation *)invocation;


#pragma mark - Stubbing

- (MCKStub *)stubCalls:(void(^)(void))callBlock;


#pragma mark - Failure Handling

- (void)failWithReason:(NSString *)reason, ... NS_FORMAT_FUNCTION(1,2);

@end
