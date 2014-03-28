//
//  MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 7.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerification.h"
#import "MCKVerificationRecorder.h"
#import "MCKVerificationGroupRecorder.h"


@class MCKLocation;
@protocol MCKVerificationResultCollector;


#pragma mark - Matching Syntax

/**
 * Match a method call on a mock or spy.
 *
 * Usage: `match ([mockObject someMethod]);`.
 */
#define mck_match(CALL, ...) _MCKRecordVerification(^{ (void)(CALL, ##__VA_ARGS__); })
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define match(CALL, ...) mck_match(CALL, ##__VA_ARGS__)
#endif

#define mck_matchGroup(COLLECTOR) _MCKRecordVerificationGroup(COLLECTOR)


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

extern MCKVerifyBlockRecorder* _mck_verify_call(MCKLocation *loc, id<MCKVerificationResultCollector> coll);
extern void _mck_setVerificationTimeout(NSTimeInterval timeout);

#define _MCKRecordVerification(BLOCK)       _MCKVerificationRecorder().recordVerification = _MCKVerification(_MCKCurrentLocation(), (BLOCK))
#define _MCKSetTimeout(TIMEOUT)             .setTimeout(TIMEOUT)
#define _MCKSetVerificationHandler(HANDLER) .setVerificationHandler(HANDLER)
extern MCKVerificationRecorder* _MCKVerificationRecorder(void);
extern MCKVerification* _MCKVerification(MCKLocation *location, MCKVerificationBlock block);

#define _MCKRecordVerificationGroup(COLLECTOR) _MCKVerificationGroupRecorder(_MCKCurrentLocation(), (COLLECTOR)).recordGroupWithBlock = ^
extern MCKVerificationGroupRecorder* _MCKVerificationGroupRecorder(MCKLocation *location, id<MCKVerificationResultCollector> collector);
