//
//  RGMockingContext.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


typedef enum {
    RGMockingContextModeRecording,
    RGMockingContextModeVerifying,
} RGMockingContextMode;


@interface RGMockingContext : NSObject

#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line;

#pragma mark - File Information

@property (nonatomic, readonly, copy)   NSString *fileName;
@property (nonatomic, readonly, assign) int       lineNumber;


#pragma mark - Handling Invocations

@property (nonatomic, assign)   RGMockingContextMode  mode;

- (void)handleInvocation:(NSInvocation *)invocation;

@end


// Mocking Syntax

#define mock_current_context() [RGMockingContext contextForTestCase:self fileName:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__]
