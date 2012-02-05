//
//  RGMockObject.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@class RGMockInvocationMatcher;


@interface RGMockRecorder : NSObject

- (id)initWithInvocationMatcher:(RGMockInvocationMatcher *)matcher; // designated initializer
- (id)init;

- (void)mock_recordInvocation:(NSInvocation *)invocation;
- (NSArray *)mock_recordedInvocations;
- (NSArray *)mock_recordedInvocationsMatchingInvocation:(NSInvocation *)invocation;

@end
