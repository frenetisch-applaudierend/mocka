//
//  MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 25.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKMockingContext;
@protocol MCKVerificationHandler;


typedef void(^MCKVerificationBlock)(void);


@interface MCKVerificationRecorder : NSObject

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context;

@property (nonatomic, readonly) MCKMockingContext *mockingContext;


#pragma mark - Properties

@property (nonatomic, readonly) MCKVerificationBlock verificationBlock;
@property (nonatomic, readonly) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, readonly) NSNumber *timeout;


#pragma mark - Property Setter Blocks

@property (nonatomic, readonly) MCKVerificationRecorder*(^setVerificationBlock)(MCKVerificationBlock block);
@property (nonatomic, readonly) MCKVerificationRecorder*(^setVerificationHandler)(id<MCKVerificationHandler> handler);
@property (nonatomic, readonly) MCKVerificationRecorder*(^setTimeout)(NSNumber *timeout);

@end
