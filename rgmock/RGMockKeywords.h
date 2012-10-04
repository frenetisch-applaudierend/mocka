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
#define verify mck_verify
#endif


#pragma mark - Stubbing

// Safe syntax
#define mck_stub      if ([mck_updatedContext() updateContextMode:RGMockContextModeStubbing])
#define mck_soItWill  if (YES)
#define mck_andItWill mck_soItWill

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define stub      mck_stub
#define soItWill  mck_soItWill
#define andItWill mck_andItWill
#endif