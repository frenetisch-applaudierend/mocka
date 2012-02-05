//
//  RGMockInvocationMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface RGMockInvocationMatcher : NSObject

- (BOOL)invocation:(NSInvocation *)invocation matchesInvocation:(NSInvocation *)candidate;

@end
