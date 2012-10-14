//
//  BlockInvocationMatcher.h
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKInvocationMatcher.h"


@interface BlockInvocationMatcher : MCKInvocationMatcher

@property (nonatomic, copy) BOOL(^matcherImplementation)(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers);

@end
