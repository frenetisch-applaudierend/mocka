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
@class MCKVerificationResult;


typedef void(^MCKVerificationGroupBlock)(void);


@interface MCKVerificationGroup : NSObject

- (instancetype)initWithMockingContext:(MCKMockingContext *)context
                             collector:(id<MCKVerificationResultCollector>)collector
                verificationGroupBlock:(MCKVerificationGroupBlock)block;

@property (nonatomic, readonly) MCKMockingContext *mockingContext;
@property (nonatomic, readonly) MCKVerificationGroupBlock verificationGroupBlock;
@property (nonatomic, readonly) id<MCKVerificationResultCollector> resultCollector;

- (MCKVerificationResult *)execute;

@end
