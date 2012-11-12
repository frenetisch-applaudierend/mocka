//
//  MCKMockingContext.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCKFailureHandler;
@protocol MCKVerificationHandler;
@protocol MCKStubAction;
@protocol MCKArgumentMatcher;
@class MCKStub;


#define mck_updatedContext() [MCKMockingContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__]
#define mck_currentContext() [MCKMockingContext currentContext]


typedef enum {
    MockaContextModeRecording,
    MockaContextModeStubbing,
    MockaContextModeVerifying,
} MockaContextMode;


@interface MCKMockingContext : NSObject


#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line;
+ (id)contextForTestCase:(id)testCase;
+ (id)currentContext;


#pragma mark - Initialization

- (id)initWithTestCase:(id)testCase;


#pragma mark - File Information and Handling Failures

@property (nonatomic, readonly, weak) id testCase;
@property (nonatomic, readonly, copy) NSString *fileName;
@property (nonatomic, readonly, assign) int lineNumber;

@property (nonatomic, readwrite, strong) id<MCKFailureHandler> failureHandler;

- (void)failWithReason:(NSString *)reason;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) MockaContextMode mode;
@property (nonatomic, strong)   id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, readonly) NSArray *recordedInvocations;

- (void)updateContextMode:(MockaContextMode)newMode;

- (void)handleInvocation:(NSInvocation *)invocation;


#pragma mark - Stubbing

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation;
- (void)addStubAction:(id<MCKStubAction>)action;


#pragma mark - Argument Matchers

@property (nonatomic, readonly, copy) NSArray *primitiveArgumentMatchers;

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher;

@end
