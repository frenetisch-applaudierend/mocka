//
//  MCKHamcrestArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKHamcrestArgumentMatcher.h"
#import "MCKArgumentMatcher+Subclasses.h"


@implementation MCKHamcrestArgumentMatcher;

#pragma mark - Initialization

+ (id)matcherWithHamcrestMatcher:(id)hamcrestMatcher
{
    return [[self alloc] initWithHamcrestMatcher:hamcrestMatcher];
}

- (id)initWithHamcrestMatcher:(id)hamcrestMatcher
{
    if ((self = [super init])) {
        _hamcrestMatcher = hamcrestMatcher;
    }
    return self;
}


#pragma mark - Matching

- (BOOL)matchesObjectCandidate:(id)candidate
{
    return (self.hamcrestMatcher != nil ? [self.hamcrestMatcher matches:candidate] : YES);
}

- (BOOL)matchesNonObjectCandidate:(NSValue *)candidate
{
    return (self.hamcrestMatcher != nil ? [self.hamcrestMatcher matches:candidate] : YES);
}

- (BOOL)matches:(id)item {
    // only here to provide signature for -matches: selector
    return NO;
}

@end
