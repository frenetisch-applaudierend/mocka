//
//  RGMockKeywords.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockingContext.h"


#pragma mark - Verify

#ifdef MOCK_SHORTHAND
    #define verify mock_verify
#endif
#define mock_verify if (mock_set_verify(mock_current_context()))

static BOOL mock_set_verify(RGMockingContext *context) {
    context.mode = RGMockingContextModeVerifying;
    return YES;
}
