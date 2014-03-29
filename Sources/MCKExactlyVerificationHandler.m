//
//  MCKExactlyVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKExactlyVerificationHandler.h"


@interface MCKExactlyVerificationHandler ()

@property (nonatomic, strong) MCKVerificationResult *lastFailure;

@end

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
        self.lastFailure = [MCKVerificationResult failureWithReason:reason matchingIndexes:[NSIndexSet indexSet]];
        return self.lastFailure;
    }
}


#pragma mark - Timeout Handling

- (BOOL)mustAwaitTimeoutForResult:(MCKVerificationResult *)result
{
    if ([result isSuccess]) {
        return YES;
    }
    else {
        // if we have already exceeded the maximum count then
        // there is no need to wait for further matches
        // (note: this means that in this case the reported number
        //        of actual calls could be wrong)
        return ([result.matchingIndexes count] < self.count);
    }
}

- (BOOL)mustAwaitTimeoutToDetermineSuccess {
    return YES;
}

@end
