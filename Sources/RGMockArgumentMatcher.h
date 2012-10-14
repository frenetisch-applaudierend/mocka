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

static inline id mck_registerObjectMatcher(id<RGMockArgumentMatcher> matcher) {
    // no need to push the matcher to the context, since it can be passed directly via argument
    return matcher;
}

static inline char mck_registerPrimitiveMatcher(id<RGMockArgumentMatcher> matcher) {
    return [[RGMockContext currentContext] pushPrimitiveArgumentMatcher:matcher];
}

static inline char* mck_registerCStringMatcher(id<RGMockArgumentMatcher> matcher) {
    return (char[]) { [[RGMockContext currentContext] pushPrimitiveArgumentMatcher:matcher], '\0' };
}

static inline SEL mck_registerSelectorMatcher(id<RGMockArgumentMatcher> matcher) {
    return (SEL)((char[]) { [[RGMockContext currentContext] pushPrimitiveArgumentMatcher:matcher], '\0' });
}

static inline void* mck_registerPointerMatcher(id<RGMockArgumentMatcher> matcher) {
    return (void *)[[RGMockContext currentContext] pushPrimitiveArgumentMatcher:matcher];
}
