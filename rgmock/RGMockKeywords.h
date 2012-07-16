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
#define mock_verify if (mock_set_verify(mock_current_context()))

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
    #define verify mock_verify
#endif

// Helper Functions
static BOOL mock_set_verify(RGMockContext *context) {
    context.mode = RGMockingContextModeVerifying;
    return YES;
}


#pragma mark - Stubbing

// Safe syntax
#define mock_stub if (YES)
#define mock_whichWill if (YES)
#define mock_andItWill mock_whichWill

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
    #define stub mock_stub
    #define whichWill mock_whichWill
    #define andItWill mock_andItWill
#endif