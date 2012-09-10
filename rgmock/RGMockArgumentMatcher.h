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
