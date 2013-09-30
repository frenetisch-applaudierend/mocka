//
//  MCKVerificationResult.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKVerificationResult.h"


@implementation MCKVerificationResult

#pragma mark - Initialization

+ (instancetype)successWithMatchingIndexes:(NSIndexSet *)matches {
    return [[self alloc] initWithSuccess:YES failureReason:nil matchingIndexes:matches];
}

+ (instancetype)failureWithReason:(NSString *)reason matchingIndexes:(NSIndexSet *)matches {
    return [[self alloc] initWithSuccess:NO failureReason:reason matchingIndexes:matches];
}

- (instancetype)initWithSuccess:(BOOL)success failureReason:(NSString *)failureReason matchingIndexes:(NSIndexSet *)matches {
    if ((self = [super init])) {
        _success = success;
        _failureReason = [failureReason copy];
        _matchingIndexes = (matches != nil ? [matches copy] : [NSIndexSet indexSet]);
    }
    return self;
}

@end
