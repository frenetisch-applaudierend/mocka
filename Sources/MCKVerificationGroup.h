//
//  MCKVerificationGroup.h
//  mocka
//
//  Created by Markus Gasser on 28.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKVerificationResultCollector;
@class MCKMockingContext;
@class MCKLocation;
@class MCKVerificationResult;
@class MCKInvocationRecorder;


typedef void(^MCKVerificationGroupBlock)(void);


@interface MCKVerificationGroup : NSObject

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
                              location:(MCKLocation *)location
                             collector:(id<MCKVerificationResultCollector>)collector
                verificationGroupBlock:(MCKVerificationGroupBlock)block;

@property (nonatomic, readonly) MCKMockingContext *mockingContext;
@property (nonatomic, readonly) MCKLocation *location;
@property (nonatomic, readonly) id<MCKVerificationResultCollector> resultCollector;
@property (nonatomic, readonly) MCKVerificationGroupBlock verificationGroupBlock;

- (MCKVerificationResult *)executeWithInvocationRecorder:(MCKInvocationRecorder *)invocationRecorder;
- (MCKVerificationResult *)collectResult:(MCKVerificationResult *)result;

@end
