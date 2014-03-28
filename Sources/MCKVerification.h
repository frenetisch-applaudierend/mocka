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


typedef void(^MCKVerificationBlock)(void);


@interface MCKVerification : NSObject

#pragma mark - Initialization

- (instancetype)initWithVerificationBlock:(MCKVerificationBlock)block location:(MCKLocation *)location;


#pragma mark - Properties

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
 * This will call the verification block, which makes sure
 * the verification call is made. Those verification calls
 * then are routed via the MCKMockingContext to the
 * MCKInvocationVerifier. The verifier in turn passes it along
 * to this object which then will check the result and return
 * it from this method.
 *
 * Exactly one verification method must be executed when calling
 * the verification block.
 *
 * @return The result of the passed verification
 */
- (MCKVerificationResult *)execute;

@end
