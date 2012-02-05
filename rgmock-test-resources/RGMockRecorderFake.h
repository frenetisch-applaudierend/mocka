//
//  RGMockObjectFake.h
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockRecorder.h"


@interface RGMockRecorderFake : RGMockRecorder

+ (id)fakeWithRealRecorder:(RGMockRecorder *)recorder;
- (id)initWithRealRecorder:(RGMockRecorder *)recorder;

- (void)fake_shouldMatchInvocation:(NSInvocation *)invocation;
- (void)fake_shouldNotMatchInvocation:(NSInvocation *)invocation;
- (BOOL)fake_didTryMatchingInvocation:(NSInvocation *)invocation;

@end
