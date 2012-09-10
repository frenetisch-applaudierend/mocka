//
//  RGMockArgumentMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockContext.h"


@protocol RGMockArgumentMatcher <NSObject>

- (BOOL)matchesCandidate:(id)candidate;

@end


// Registering Matchers

static inline char mock_registerPrimitiveMatcher(id<RGMockArgumentMatcher> matcher) {
    return [[RGMockContext currentContext] pushArgumentMatcher:matcher];
}

static inline id mock_registerObjectMatcher(id<RGMockArgumentMatcher> matcher) {
    return @([[RGMockContext currentContext] pushArgumentMatcher:matcher]);
}

static inline char* mock_registerCStringMatcher(id<RGMockArgumentMatcher> matcher) {
    return (char *)[[RGMockContext currentContext] pushArgumentMatcher:matcher];
}

static inline SEL mock_registerSelectorMatcher(id<RGMockArgumentMatcher> matcher) {
    return (SEL)[[RGMockContext currentContext] pushArgumentMatcher:matcher];
}

static inline void* mock_registerPointerMatcher(id<RGMockArgumentMatcher> matcher) {
    return (void *)[[RGMockContext currentContext] pushArgumentMatcher:matcher];
}
