//
//  MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 26.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKVerificationHandler;
@class MCKVerificationResult;
@class MCKLocation;
@class MCKMockingContext;


typedef void(^MCKVerificationBlock)(void);


@interface MCKVerification : NSObject

#pragma mark - Initialization

- (instancetype)initWithMockingContext:(MCKMockingContext *)context location:(MCKLocation *)location verificationBlock:(MCKVerificationBlock)block;


#pragma mark - Properties

@property (nonatomic, readonly) MCKMockingContext *mockingContext;
@property (nonatomic, readonly) MCKLocation *location;
@property (nonatomic, readonly) MCKVerificationBlock verificationBlock;
@property (nonatomic, readonly) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, readonly) NSTimeInterval timeout;


#pragma mark - Configuration

@property (nonatomic, readonly) MCKVerification*(^setVerificationHandler)(id<MCKVerificationHandler> handler);
@property (nonatomic, readonly) MCKVerification*(^setTimeout)(NSTimeInterval timeout);


#pragma mark - Execution

/**
 * Execute the current verification.
 *
 * Exactly one verification method must be executed when calling
 * the verification block.
 *
 * @return The result of the passed verification
 */
- (MCKVerificationResult *)execute;

@end
