//
//  MCKAnyArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKAnyArgumentMatcher.h"


@implementation MCKAnyArgumentMatcher

#pragma mark - Argument Matching

- (BOOL)matchesCandidate:(id)candidate {
    return YES;
}


#pragma mark - NSCopying Support

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
