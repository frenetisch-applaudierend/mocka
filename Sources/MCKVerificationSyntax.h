//
//  MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 7.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerificationRecorder.h"
#import "MCKVerification.h"


@class MCKLocation;
@protocol MCKVerificationResultCollector;


#pragma mark - Verification Syntax

/**
 * Start verification of a single call.
 *
 * Usage: `verifyCall ([mockObject someMethod]);`.
 */
#define mck_verifyCall(CALL, ...) _mck_verify_call(_MCKCurrentLocation(), nil).verifyCallBlock = ^{ (void)(CALL, ## __VA_ARGS__); }
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define verifyCall(CALL, ...) mck_verifyCall(CALL, ## __VA_ARGS__)
#endif


/**
 * Start group verification using a collector.
 *
 * Intended to be wrapped in your own macro, so there is no nice syntax option.
 */
#define mck_verifyUsingCollector(COLL) _mck_verify_call(_MCKCurrentLocation(), (COLL)).verifyCallBlock = ^


/**
 * Set a verification timeout per call
 *
 * Usage: `verifyCall (withTimeout(0.5) [mockObject someMethod]);`.
 */
#define mck_withTimeout(T) _mck_setVerificationTimeout(T),
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define withTimeout(T) mck_withTimeout(T)
#endif


#pragma mark - Internal

@interface MCKVerifyBlockRecorder : NSObject

@property (nonatomic, copy) void(^verifyCallBlock)(void);

@end

#define _MCKRecordVerification(VERIFICATION) _MCKRecorder().recordVerification = _MCKVerification((VERIFICATION), _MCKCurrentLocation())

extern MCKVerificationRecorder* _MCKRecorder(void);
extern MCKVerification* _MCKVerification(MCKVerificationBlock block, MCKLocation *location);

extern MCKVerifyBlockRecorder* _mck_verify_call(MCKLocation *loc, id<MCKVerificationResultCollector> coll);
extern void _mck_setVerificationTimeout(NSTimeInterval timeout);
