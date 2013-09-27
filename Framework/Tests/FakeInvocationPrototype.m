//
//  FakeInvocationPrototype.m
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "FakeInvocationPrototype.h"


@implementation FakeInvocationPrototype

#pragma mark - Initialization

+ (instancetype)thatAlwaysMatches {
    return [self withImplementation:^BOOL(NSInvocation *candidate) {
        return YES;
    }];
}

+ (instancetype)thatNeverMatches {
    return [self withImplementation:^BOOL(NSInvocation *candidate) {
        return NO;
    }];
}

+ (instancetype)withImplementation:(BOOL(^)(NSInvocation *candidate))matcher {
    return [[self alloc] initWithMatcherImplementation:matcher];
}

- (instancetype)initWithMatcherImplementation:(BOOL(^)(NSInvocation *candidate))matcher {
    NSParameterAssert(matcher != nil);
    
    if ((self = [super initWithInvocation:nil argumentMatchers:nil])) {
        _matcherImplementation = [matcher copy];
    }
    return self;
}

- (BOOL)matchesInvocation:(NSInvocation *)candidate {
    return (_matcherImplementation != nil ? _matcherImplementation(candidate) : [super matchesInvocation:candidate]);
}

@end
