//
//  MCKInOrderCollector.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKInOrderCollector.h"


@interface MCKInOrderCollector ()

@property (nonatomic, readonly) NSMutableArray *skippedInvocations;

@end


@implementation MCKInOrderCollector

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _skippedInvocations = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Collecting and Processing Results

- (MCKVerificationResult *)collectVerificationResult:(MCKVerificationResult *)result forInvocations:(NSMutableArray *)invocations {
    // remove invocations and record skipped invocations
    __block NSUInteger maxIndex = 0;
    [result.matchingIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexSet *skippedInvocations = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (idx - maxIndex))];
        [self.skippedInvocations addObjectsFromArray:[invocations objectsAtIndexes:skippedInvocations]];
        [invocations removeObjectsInRange:NSMakeRange(0, (idx - maxIndex + 1))];
        maxIndex = (idx + 1);
    }];
    return result;
}

- (MCKVerificationResult *)processCollectedResultsWithInvocations:(NSMutableArray *)invocations {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.skippedInvocations count])];
    [invocations insertObjects:self.skippedInvocations atIndexes:indexes];
    return nil;
}

@end
