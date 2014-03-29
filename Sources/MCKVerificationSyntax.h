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

#define mck_withTimeout(TIMEOUT) _MCKSetTimeout(TIMEOUT)
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define withTimeout(TIMEOUT) mck_withTimeout(TIMEOUT)
#endif


#pragma mark - Internal

#define _MCKRecordVerification(BLOCK)       _MCKVerificationRecorder().recordVerification = _MCKVerification(_MCKCurrentLocation(), (BLOCK))
#define _MCKSetTimeout(TIMEOUT)             .setTimeout(TIMEOUT)
#define _MCKSetVerificationHandler(HANDLER) .setVerificationHandler(HANDLER)
extern MCKVerificationRecorder* _MCKVerificationRecorder(void);
extern MCKVerification* _MCKVerification(MCKLocation *location, MCKVerificationBlock block);

#define _MCKRecordVerificationGroup(COLLECTOR) _MCKVerificationGroupRecorder(_MCKCurrentLocation(), (COLLECTOR)).recordGroupWithBlock = ^
extern MCKVerificationGroupRecorder* _MCKVerificationGroupRecorder(MCKLocation *location, id<MCKVerificationResultCollector> collector);
