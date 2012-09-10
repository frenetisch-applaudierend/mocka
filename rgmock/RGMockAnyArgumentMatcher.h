//
//  RGMockAnyArgumentMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockArgumentMatcher.h"


@interface RGMockAnyArgumentMatcher : NSObject <RGMockArgumentMatcher>

@end


// Mocking Syntax
static char mock_anyInt(void) {
    return mock_registerPrimitiveMatcher([[RGMockAnyArgumentMatcher alloc] init]);
}

#ifndef MOCK_DISABLE_NICE_SYNTAX
static char anyInt(void) {
    return mock_anyInt();
}
#endif
