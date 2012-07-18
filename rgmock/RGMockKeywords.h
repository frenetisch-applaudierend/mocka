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
#define mock_verify if ([mock_current_context() updateContextMode:RGMockContextModeVerifying])

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
    #define verify mock_verify
#endif


#pragma mark - Stubbing

// Safe syntax
#define mock_stub if (YES)
#define mock_soThatItWill if (YES)
#define mock_andItWill mock_soThatItWill

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
    #define stub mock_stub
    #define soThatItWill mock_soThatItWill
    #define andItWill mock_andItWill
#endif