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

void mck_giveSignal(NSString *signal);
void mck_signalGiven(NSString *signal, NSTimeInterval timeout);

#ifndef MOCK_DISABLE_NICE_SYNTAX
static inline void giveSignal(NSString *signal) { mck_giveSignal(signal); }
static inline void signalGiven(NSString *signal, NSTimeInterval timeout) { mck_signalGiven(signal, timeout); }
#endif
