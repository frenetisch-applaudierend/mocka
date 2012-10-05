//
//  RGMockKeywords.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"


#pragma mark - Verifying

// Safe syntax
#define mck_verify if ([mck_updatedContext() updateContextMode:RGMockContextModeVerifying])

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#undef verify // under Mac OS X this macro defined already (in /usr/include/AssertMacros.h)
#define verify mck_verify
#endif


#pragma mark - Stubbing

// Safe syntax
#define mck_whenCalling   if ([mck_updatedContext() updateContextMode:RGMockContextModeStubbing])
#define mck_orWhenCalling ; mck_whenCalling
#define mck_thenItWill    ; if (YES)
#define mck_andItWill     mck_thenItWill

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define whenCalling   mck_whenCalling
#define orWhenCalling mck_orWhenCalling
#define thenItWill    mck_thenItWill
#define andItWill     mck_andItWill
#endif