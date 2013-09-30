//
//  FakeVerificationResultCollector.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mocka/MCKVerificationResultCollector.h>


@interface FakeVerificationResultCollector : NSObject <MCKVerificationResultCollector>

+ (instancetype)collector;
+ (instancetype)collectorWithMergedResult:(MCKVerificationResult *)result;

@property (nonatomic, readonly) NSArray *collectedResults;
@property (nonatomic, readonly) MCKVerificationResult *mergedResult;

@end
