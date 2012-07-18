//
//  RGMockingContext.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

@protocol RGMockVerificationHandler;
@protocol RGMockStubAction;
@class RGMockStubbing;


#define mock_current_context() [RGMockContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__]

typedef enum {
    RGMockContextModeRecording,
    RGMockContextModeStubbing,
    RGMockContextModeVerifying,
} RGMockContextMode;


@interface RGMockContext : NSObject


#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line;


#pragma mark - File Information and Handling Failures

@property (nonatomic, readonly, copy)   NSString *fileName;
@property (nonatomic, readonly, assign) int       lineNumber;

- (void)failWithReason:(NSString *)reason;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) RGMockContextMode              mode;
@property (nonatomic, strong)   id<RGMockVerificationHandler>  verificationHandler;
@property (nonatomic, readonly) NSArray                       *recordedInvocations;

- (BOOL)updateContextMode:(RGMockContextMode)newMode;

- (void)handleInvocation:(NSInvocation *)invocation;


#pragma mark - Stubbing

- (RGMockStubbing *)stubbingForInvocation:(NSInvocation *)invocation;
- (void)addStubAction:(id<RGMockStubAction>)action;

@end
