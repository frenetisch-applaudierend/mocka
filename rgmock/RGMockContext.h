//
//  RGMockingContext.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

@protocol RGMockVerificationHandler;


#define mock_current_context() [RGMockContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__]

typedef enum {
    RGMockingContextModeRecording,
    RGMockingContextModeVerifying,
} RGMockingContextMode;


@interface RGMockContext : NSObject

#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line;

#pragma mark - File Information

@property (nonatomic, readonly, copy)   NSString *fileName;
@property (nonatomic, readonly, assign) int       lineNumber;


#pragma mark - Handling Invocations

@property (nonatomic, assign)   RGMockingContextMode           mode;
@property (nonatomic, strong)   id<RGMockVerificationHandler>  verificationHandler;
@property (nonatomic, readonly) NSArray                       *recordedInvocations;

- (void)handleInvocation:(NSInvocation *)invocation;

@end
