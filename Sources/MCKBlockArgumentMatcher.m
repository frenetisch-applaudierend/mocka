//
//  MCKBlockArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKBlockArgumentMatcher.h"


@implementation MCKBlockArgumentMatcher

#pragma mark - Initialization

- (id)initWithMatcherBlock:(BOOL(^)(id candidate))matcherBlock {
    if ((self = [super init])) {
        _matcherBlock = [matcherBlock copy];
    }
    return self;
}

- (id)init {
    return [self initWithMatcherBlock:nil];
}


#pragma mark - Candidate Matching

- (BOOL)matchesCandidate:(id)candidate {
    return (_matcherBlock != nil ? _matcherBlock(candidate) : YES);
}

@end
