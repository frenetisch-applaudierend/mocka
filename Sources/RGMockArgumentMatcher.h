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

static inline char mck_registerPrimitiveMatcher(id<RGMockArgumentMatcher> matcher) {
    return [[RGMockContext currentContext] pushNonObjectArgumentMatcher:matcher];
}

static inline id mck_registerObjectMatcher(id<RGMockArgumentMatcher> matcher) {
    return matcher;
}

static inline char* mck_registerCStringMatcher(id<RGMockArgumentMatcher> matcher) {
    return (char[]) { [[RGMockContext currentContext] pushNonObjectArgumentMatcher:matcher], '\0' };
}

static inline SEL mck_registerSelectorMatcher(id<RGMockArgumentMatcher> matcher) {
    return (SEL)((char[]) { [[RGMockContext currentContext] pushNonObjectArgumentMatcher:matcher], '\0' });
}

static inline void* mck_registerPointerMatcher(id<RGMockArgumentMatcher> matcher) {
    return (void *)[[RGMockContext currentContext] pushNonObjectArgumentMatcher:matcher];
}
