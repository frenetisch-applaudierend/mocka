//
//  MCKArgumentMatcherRecorder.m
//  mocka
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKArgumentMatcherRecorder.h"
#import "MCKTypeEncodings.h"
#import "MCKMockingContext.h"


@interface MCKArgumentMatcherRecorder ()

@property (nonatomic, readonly) NSMutableArray *mutablePrimitiveMatchers;
@property (nonatomic, readonly) NSMutableArray *mutableObjectMatchers;

@end

@implementation MCKArgumentMatcherRecorder

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _mutablePrimitiveMatchers = [NSMutableArray array];
        _mutableObjectMatchers = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Adding Matchers

- (NSArray *)argumentMatchers {
    return [self.mutablePrimitiveMatchers arrayByAddingObjectsFromArray:self.mutableObjectMatchers];
}

- (NSArray *)collectAndReset {
    NSArray *matchers = self.argumentMatchers;
    [self reset];
    return matchers;
}

- (UInt8)addPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if ([self.mutablePrimitiveMatchers count] > UINT8_MAX) {
        [[MCKMockingContext currentContext] failWithReason:@"Only UINT8_MAX primitive matchers supported"];
        return UINT8_MAX;
    }
    [self.mutablePrimitiveMatchers addObject:matcher];
    return ([self.mutablePrimitiveMatchers count] - 1);
}

- (void)reset {
    [self.mutablePrimitiveMatchers removeAllObjects];
    [self.mutableObjectMatchers removeAllObjects];
}


#pragma mark - Validating the Collection

- (BOOL)isValidForMethodSignature:(NSMethodSignature *)signature reason:(NSString **)reason {
    if ([self.mutablePrimitiveMatchers count] == 0) {
        return YES;
    }
    
    NSUInteger signaturePrimitiveArgs = [self countPrimitiveArgumentsOfSignature:signature];
    if (signaturePrimitiveArgs > [self.mutablePrimitiveMatchers count]) {
        if (reason != NULL) { *reason = @"When using argument matchers, all non-object arguments must be matchers"; }
        return NO;
    } else if (signaturePrimitiveArgs < [self.mutablePrimitiveMatchers count]) {
        if (reason != NULL) { *reason = @"Too many primitive matchers for this method invocation"; }
        return NO;
    }
    return YES;
}

- (NSUInteger)countPrimitiveArgumentsOfSignature:(NSMethodSignature *)signature {
    NSUInteger primitiveArgumentCount = 0;
    for (NSUInteger argIndex = 2; argIndex < [signature numberOfArguments]; argIndex++) {
        if (![MCKTypeEncodings isObjectType:[signature getArgumentTypeAtIndex:argIndex]]) {
            primitiveArgumentCount++;
        }
    }
    return primitiveArgumentCount;
}

@end
