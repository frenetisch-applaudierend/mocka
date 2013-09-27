//
//  MCKInvocationMatcher.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationMatcher.h"
#import "MCKInvocationPrototype.h"


@implementation MCKInvocationMatcher

#pragma mark - Initialization

+ (id)matcher {
    static id sharedMatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMatcher = [[MCKInvocationMatcher alloc] init];
    });
    return sharedMatcher;
}


#pragma mark - Invocation Matching

- (BOOL)invocation:(NSInvocation *)candidate
  matchesPrototype:(NSInvocation *)prototypeInvocation
withPrimitiveArgumentMatchers:(NSArray *)matchers
{
    NSParameterAssert(candidate != nil);
    NSParameterAssert(prototypeInvocation != nil);
    
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:prototypeInvocation
                                                                          argumentMatchers:matchers];
    return [prototype matchesInvocation:candidate];
}

@end
