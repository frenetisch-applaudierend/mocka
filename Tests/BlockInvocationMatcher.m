//
//  BlockInvocationMatcher.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "BlockInvocationMatcher.h"

@implementation BlockInvocationMatcher

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)matchers {
    if (_matcherImplementation != nil) {
        return _matcherImplementation(candidate, prototype, matchers);
    } else {
        return YES;
    }
}

@end
