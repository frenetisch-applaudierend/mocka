//
//  MCKExactArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKExactArgumentMatcher.h"


@implementation MCKExactArgumentMatcher

#pragma mark - Initialization

+ (id)matcherWithArgument:(id)expected {
    return [[self alloc] initWithArgument:expected];
}

- (id)initWithArgument:(id)expected {
    if ((self = [super init])) {
        [self setExpectedArgument:expected];
    }
    return self;
}

- (id)init {
    return [self initWithArgument:nil];
}


#pragma mark - Configuration

- (void)setExpectedArgument:(id)expectedArgument {
    _expectedArgument = ([expectedArgument conformsToProtocol:@protocol(NSCopying)] ? [expectedArgument copy] : expectedArgument);
}


#pragma mark - Argument Matching

- (BOOL)matchesCandidate:(id)candidate {
    return (candidate == _expectedArgument || (candidate != nil && _expectedArgument != nil && [candidate isEqual:_expectedArgument]));
}

@end
