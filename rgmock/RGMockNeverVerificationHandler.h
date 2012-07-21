//
//  RGMockNeverVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockVerificationHandler.h"


@interface RGMockNeverVerificationHandler : NSObject <RGMockVerificationHandler>

+ (id)neverHandler;

@end


// Mocking Syntax
#define mock_never mock_set_verification_handler([RGMockNeverVerificationHandler neverHandler])

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define never mock_never
#endif
