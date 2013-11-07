//
//  FakeVerificationResultCollector.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "FakeVerificationResultCollector.h"


@interface FakeVerificationResultCollector ()

@property (nonatomic, readonly) NSMutableArray *mutableCollectedResults;

@end


@implementation FakeVerificationResultCollector

#pragma mark - Initialization

+ (instancetype)dummy {
    return [self collectorWithSuccessfulResult];
}

+ (instancetype)collectorWithSuccessfulResult {
    return [[self alloc] initWithMergedResult:[MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]]];
}

+ (instancetype)collectorWithMergedResult:(MCKVerificationResult *)result {
    return [[self alloc] initWithMergedResult:result];
}

- (instancetype)initWithMergedResult:(MCKVerificationResult *)result {
    if ((self = [super init])) {
        _mergedResult = result;
        _mutableCollectedResults = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Collector Methods

- (void)beginCollectingResultsWithInvocationRecorder:(MCKInvocationRecorder *)invocationRecorder {
    _invocationRecorder = invocationRecorder;
}

- (MCKVerificationResult *)collectVerificationResult:(MCKVerificationResult *)result {
    [self.mutableCollectedResults addObject:result];
    return result;
}

- (MCKVerificationResult *)finishCollectingResults {
    return self.mergedResult;
}


#pragma mark - Getting Collected Results

- (NSArray *)collectedResults {
    return [self.mutableCollectedResults copy];
}

@end
