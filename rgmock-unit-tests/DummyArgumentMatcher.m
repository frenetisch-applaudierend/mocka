//
//  DummyArgumentMatcher.m
//  rgmock
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "DummyArgumentMatcher.h"

@implementation DummyArgumentMatcher

- (BOOL)matchesCandidate:(id)candidate {
    if (_matcherImplementation != nil) {
        return _matcherImplementation(candidate);
    } else {
        return YES;
    }
}

@end
