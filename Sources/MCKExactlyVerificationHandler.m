//
//  MCKExactlyVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKExactlyVerificationHandler.h"


@implementation MCKExactlyVerificationHandler

#pragma mark - Initialization

+ (instancetype)exactlyHandlerWithCount:(NSUInteger)count {
    return [[self alloc] initWithCount:count];
}

- (instancetype)initWithCount:(NSUInteger)count {
    if ((self = [super init])) {
        _count = count;
    }
    return self;
}


#pragma mark - Verifying Invocations

- (MCKVerificationResult *)verifyInvocations:(NSArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype {
    NSIndexSet *indexes = [invocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *invocation, NSUInteger idx, BOOL *stop) {
        return [prototype matchesInvocation:invocation];
    }];
    
    if ([indexes count] == self.count) {
        return [MCKVerificationResult successWithMatchingIndexes:indexes];
    } else {
        NSString *reason = [NSString stringWithFormat:@"Expected exactly %ld calls to %@ but got %ld",
                            (unsigned long)self.count, prototype.methodName, (unsigned long)[indexes count]];
        return [MCKVerificationResult failureWithReason:reason matchingIndexes:[NSIndexSet indexSet]];
    }
}


#pragma mark - Timeout Handling

- (BOOL)mustAwaitTimeoutForFailure {
    return YES;
}

@end
