//
//  BlockInvocationMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockInvocationMatcher.h"


@interface BlockInvocationMatcher : RGMockInvocationMatcher

@property (nonatomic, copy) BOOL(^matcherImplementation)(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers);

@end
