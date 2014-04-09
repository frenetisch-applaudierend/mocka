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

SInt8 mck_intArg(SInt64 arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)], SInt8);
}

UInt8 mck_unsignedIntArg(UInt64 arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)], UInt8);
}

float mck_floatArg(float arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)], float);
}

double mck_doubleArg(double arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)], double);
}

BOOL mck_boolArg(BOOL arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)], BOOL);
}

char* mck_cStringArg(const char *arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]], char*);
}

SEL mck_selectorArg(SEL arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]], SEL);
}

void* mck_pointerArg(const void *arg) {
    return MCKRegisterMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]], void*);
}
