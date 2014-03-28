//
//  HCBlockMatcher.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "HCBlockMatcher.h"


@implementation HCBlockMatcher

+ (id)matcherWithBlock:(BOOL(^)(id candidate))block {
    NSParameterAssert(block != nil);
    HCBlockMatcher *matcher = [[self alloc] init];
    matcher.matcherBlock = block;
    return matcher;
}

- (BOOL)matches:(id)item {
    return (_matcherBlock != nil ? _matcherBlock(item) : YES);
}

- (BOOL)matches:(id)item describingMismatchTo:(id<HCDescription>)mismatchDescription {
    return [self matches:item];
}

- (void)describeMismatchOf:(id)item to:(id<HCDescription>)mismatchDescription {
}

- (void)describeTo:(id<HCDescription>)description {
}

@end
