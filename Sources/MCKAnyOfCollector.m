//
//  MCKAnyOfCollector.m
//  mocka
//
//  Created by Markus Gasser on 29.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKAnyOfCollector.h"


@interface MCKAnyOfCollector ()

@property (nonatomic, strong) MCKInvocationRecorder *invocationRecorder;
@property (nonatomic, assign) BOOL succesful;

@end

@implementation MCKAnyOfCollector

- (void)beginCollectingResultsWithInvocationRecorder:(MCKInvocationRecorder *)invocationRecorder
{
    self.invocationRecorder = invocationRecorder;
}

- (MCKVerificationResult *)collectVerificationResult:(MCKVerificationResult *)result
{
    if ([result isSuccess]) {
        [self.invocationRecorder removeInvocationsAtIndexes:result.matchingIndexes];
        self.succesful = YES;
        return result;
    }
    else {
        return [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    }
}

- (MCKVerificationResult *)finishCollectingResults
{
    return (self.succesful
            ? [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]]
            : [MCKVerificationResult failureWithReason:@"None of the invocations matched" matchingIndexes:[NSIndexSet indexSet]]);
}

@end
