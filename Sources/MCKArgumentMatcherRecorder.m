//
//  MCKArgumentMatcherRecorder.m
//  mocka
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKArgumentMatcherRecorder.h"
#import "MCKTypeEncodings.h"
#import "MCKAPIMisuse.h"


@interface MCKArgumentMatcherRecorder ()

@property (nonatomic, assign) NSUInteger primitiveMatcherCount;
@property (nonatomic, readonly) NSMutableArray *mutableArgumentMatchers;

@end

@implementation MCKArgumentMatcherRecorder

#pragma mark - Initialization

- (instancetype)init
{
    if ((self = [super init])) {
        _mutableArgumentMatchers = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Adding Matchers

- (NSArray *)argumentMatchers
{
    return [self.mutableArgumentMatchers copy];
}

- (NSArray *)collectAndReset
{
    NSArray *matchers = self.argumentMatchers;
    [self reset];
    return matchers;
}

- (UInt8)addPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher
{
    self.primitiveMatcherCount++;
    return [self addArgumentMatcher:matcher];
}

- (UInt8)addObjectArgumentMatcher:(id<MCKArgumentMatcher>)matcher
{
    return [self addArgumentMatcher:matcher];
}

- (UInt8)addArgumentMatcher:(id<MCKArgumentMatcher>)matcher
{
    if ([self.mutableArgumentMatchers count] > UINT8_MAX) {
        MCKAPIMisuse(@"At most %d matchers supported", UINT8_MAX);
    }
    
    [self.mutableArgumentMatchers addObject:matcher];
    return ([self.mutableArgumentMatchers count] - 1);
}

- (void)reset
{
    [self.mutableArgumentMatchers removeAllObjects];
    self.primitiveMatcherCount = 0;
}


#pragma mark - Validating the Recorder

- (void)validateForMethodSignature:(NSMethodSignature *)signature
{
    if (self.primitiveMatcherCount == 0) {
        return;
    }
    
    NSUInteger argCount = [self countPrimitiveArgumentsOfSignature:signature];
    if (self.primitiveMatcherCount < argCount) {
        MCKAPIMisuse(@"When using argument matchers, all non-object arguments must be matchers");
    }
    else if (self.primitiveMatcherCount > argCount) {
        MCKAPIMisuse(@"Too many primitive matchers found (got %ld need only %ld)", (unsigned long)self.primitiveMatcherCount, (unsigned long)argCount);
    }
}

- (NSUInteger)countPrimitiveArgumentsOfSignature:(NSMethodSignature *)signature
{
    NSUInteger primitiveArgumentCount = 0;
    for (NSUInteger argIndex = 2; argIndex < [signature numberOfArguments]; argIndex++) {
        if (![MCKTypeEncodings isObjectType:[signature getArgumentTypeAtIndex:argIndex]]) {
            primitiveArgumentCount++;
        }
    }
    return primitiveArgumentCount;
}

@end
