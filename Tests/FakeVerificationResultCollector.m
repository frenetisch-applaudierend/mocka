//
//  FakeVerificationResultCollector.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "FakeVerificationResultCollector.h"


@implementation FakeVerificationResultCollector

#pragma mark - Initialization

+ (instancetype)collector {
    return [[self alloc] initWithMergedResult:[MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]]];
}

+ (instancetype)collectorWithMergedResult:(MCKVerificationResult *)result {
    return [[self alloc] initWithMergedResult:result];
}

- (instancetype)initWithMergedResult:(MCKVerificationResult *)result {
    if ((self = [super init])) {
        _mergedResult = result;
    }
    return self;
}

- (MCKVerificationResult *)resultByMergingResults:(NSArray *)results {
    _collectedResults = [results copy];
    return self.mergedResult;
}

@end
