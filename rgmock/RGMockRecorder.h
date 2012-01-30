//
//  RGMockObject.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface RGMockRecorder : NSObject

- (void)mock_recordInvocation:(NSInvocation *)invocation;
- (NSArray *)mock_recordedInvocations;
- (NSArray *)mock_recordedInvocationsMatchingInvocation:(NSInvocation *)invocation;

@end
