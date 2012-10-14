//
//  RGMockInvocationMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RGMockInvocationMatcher : NSObject

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)matchers;

@end
