//
//  MCKVerificationGroupRecorder.h
//  mocka
//
//  Created by Markus Gasser on 29.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerificationGroup.h"


@class MCKMockingContext;
@class MCKLocation;
@protocol MCKVerificationResultCollector;


@interface MCKVerificationGroupRecorder : NSObject

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
                              location:(MCKLocation *)location
                       resultCollector:(id<MCKVerificationResultCollector>)collector;

@property (nonatomic, readonly) MCKMockingContext *mockingContext;
@property (nonatomic, readonly) MCKLocation *location;
@property (nonatomic, readonly) id<MCKVerificationResultCollector> resultCollector;

@property (nonatomic, copy) MCKVerificationGroupBlock recordGroupWithBlock;

@end
