//
//  MCKVerificationResultCollector.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mocka/MCKVerificationResult.h>


@protocol MCKVerificationResultCollector <NSObject>

- (MCKVerificationResult *)collectedResultFromResults:(NSArray *)results;

@end
