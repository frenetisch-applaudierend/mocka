//
//  RGMockInvocationMatcherFake.h
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationMatcher.h"

@interface RGMockInvocationMatcherFake : RGMockInvocationMatcher

- (void)fake_shouldMatchInvocation:(NSInvocation *)invocation withInvocation:(NSInvocation *)candidate;

@end
