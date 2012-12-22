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

+ (id)matcherWithBlock:(BOOL(^)(id candidate))block {
    NSParameterAssert(block != nil);
    MCKBlockArgumentMatcher *matcher = [[MCKBlockArgumentMatcher alloc] init];
    matcher.matcherBlock = block;
    return matcher;
}


#pragma mark - Candidate Matching

- (BOOL)matchesCandidate:(id)candidate {
    return (_matcherBlock != nil ? _matcherBlock(candidate) : YES);
}

@end
