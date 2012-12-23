//
//  MCKTimeoutVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerificationHandler.h"


@interface MCKTimeoutVerificationHandler : NSObject <MCKVerificationHandler>

+ (id)timeoutHandlerWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler;

@end


// Mocking Syntax
#define mck_withTimeout(t) mck_setVerificationHandler(\
    [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:(t) currentVerificationHandler:[mck_currentContext() verificationHandler]]\
)

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define withTimeout(t) mck_withTimeout(t)
#endif
