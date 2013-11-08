//
//  MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 7.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKLocation;
@protocol MCKVerificationResultCollector;


#pragma mark - Verification Syntax

/**
 * Start verification of a single call.
 *
 * Usage: `verify ([mockObject someMethod]);`.
 */
#define mck_verify(...) _mck_verify(self, _MCKCurrentLocation(), nil).verifyCallBlock = ^{ (void)(__VA_ARGS__); }
#ifndef MCK_DISABLE_NICE_SYNTAX
    #undef verify
    #define verify(...) mck_verify(__VA_ARGS__)
#endif


/**
 * Start group verification using a collector.
 *
 * Intended to be wrapped in your own macro, so there is no nice syntax option.
 */
#define mck_verifyUsingCollector(COLL) _mck_verify(self, _MCKCurrentLocation(), (COLL)).verifyCallBlock = ^


/**
 * Set a verification timeout per call
 *
 * Usage: `verify (withTimeout(0.5) [mockObject someMethod]);`.
 */
#define mck_withTimeout(T) _mck_setVerificationTimeout(self, T),
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define withTimeout(T) mck_withTimeout(T)
#endif


#pragma mark - Internal

@interface MCKVerifyBlockRecorder : NSObject

@property (nonatomic, copy) void(^verifyCallBlock)(void);

@end

extern MCKVerifyBlockRecorder* _mck_verify(id testCase, MCKLocation *loc, id<MCKVerificationResultCollector> coll);
extern void _mck_setVerificationTimeout(id testCase, NSTimeInterval timeout);
