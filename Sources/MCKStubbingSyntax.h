//
//  MCKStubbingSyntax.h
//  mocka
//
//  Created by Markus Gasser on 8.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKLocation;
@class MCKStub;


/**
 * Stub one or more method calls
 */
#define mck_stub(CALL, ...) _mck_stub(_MCKCurrentLocation(), ^{ (CALL, ##__VA_ARGS__); }).stubBlock = ^typeof((CALL, ##__VA_ARGS__))
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define stub(CALL, ...) mck_stub(CALL, ##__VA_ARGS__)
#endif


/**
 * Provide actions for stubbed calls.
 */
#define mck_with
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define with mck_with
#endif


#pragma mark - Internal

extern MCKStub* _mck_stub(MCKLocation *location, void(^calls)(void));
