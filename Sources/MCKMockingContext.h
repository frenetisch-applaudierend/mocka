//
//  MCKMockingContext.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKInvocationStubber;
@class MCKInvocationVerifier;
@class MCKArgumentMatcherRecorder;
@protocol MCKFailureHandler;

@class MCKLocation;


@protocol MCKVerificationHandler;
@protocol MCKArgumentMatcher;
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


#pragma mark - Core Objects

@property (nonatomic, strong) NSMutableArray *mutableRecordedInvocations;
@property (nonatomic, strong) MCKInvocationStubber *invocationStubber;
@property (nonatomic, strong) MCKInvocationVerifier *invocationVerifier;
@property (nonatomic, strong) MCKArgumentMatcherRecorder *argumentMatcherRecorder;
@property (nonatomic, strong) id<MCKFailureHandler> failureHandler;


#pragma mark - File Location Data

@property (nonatomic, copy) MCKLocation *currentLocation;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) MCKContextMode mode;

- (void)updateContextMode:(MCKContextMode)newMode;

- (void)handleInvocation:(NSInvocation *)invocation;




#pragma mark - Recording

@property (nonatomic, readonly) NSArray *recordedInvocations;

@end
