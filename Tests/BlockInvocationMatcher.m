//
//  BlockInvocationMatcher.m
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "BlockInvocationMatcher.h"

@implementation BlockInvocationMatcher

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype withNonObjectArgumentMatchers:(NSArray *)matchers {
    if (_matcherImplementation != nil) {
        return _matcherImplementation(candidate, prototype, matchers);
    } else {
        return YES;
    }
}

@end
