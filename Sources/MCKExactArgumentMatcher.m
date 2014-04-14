//
//  MCKExactArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKExactArgumentMatcher.h"
#import "MCKArgumentMatcher+Subclasses.h"


@implementation MCKExactArgumentMatcher

#pragma mark - Initialization

+ (instancetype)matcherWithArgument:(id)expected
{
    return [[self alloc] initWithArgument:expected];
}

- (instancetype)initWithArgument:(id)expected
{
    if ((self = [super init])) {
        [self setExpectedArgument:expected];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithArgument:nil];
}


#pragma mark - Configuration

- (void)setExpectedArgument:(id)expectedArgument
{
    _expectedArgument = ([expectedArgument conformsToProtocol:@protocol(NSCopying)]
                         ? [expectedArgument copy]
                         : expectedArgument);
}


#pragma mark - Argument Matching

- (BOOL)matchesObjectCandidate:(id)candidate
{
    return (candidate == self.expectedArgument || (candidate != nil && [candidate isEqual:self.expectedArgument]));
}

- (BOOL)matchesNonObjectCandidate:(NSValue *)candidate
{
    return (candidate == self.expectedArgument || (candidate != nil && [candidate isEqual:self.expectedArgument]));
}


#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p expected=%@>", [self class], self, self.expectedArgument];
}

@end



#pragma mark - Mocking Syntax

MCKExactArgumentMatcher* _MCKCreateExactMatcherFromBytesAndType(const void *bytes, const char *type)
{
    return [[MCKExactArgumentMatcher alloc] initWithArgument:MCKSerializeValueFromBytesAndType(bytes, type)];
}
