//
//  MCKTimeoutVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerificationHandler.h"
#import "MCKUtilities.h"


@interface MCKTimeoutVerificationHandler : NSObject <MCKVerificationHandler>

+ (id)timeoutHandlerWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler;

@end


// Mocking Syntax
#define mck_withTimeout(t) _mck_setVerificationHandler(\
    [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:(t) currentVerificationHandler:_mck_getVerificationHandler()]\
);

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define withTimeout(t) mck_withTimeout(t)
#endif


// Signaling
#define mck_giveSignal(signal) MCKSuppressRetainCylceWarning({\
    _mck_updateLocationInfo(__FILE__, __LINE__); _mck_issueSignalInternal(signal);\
})
#define mck_signalGiven(signal) mck_giveSignal(signal)
void _mck_issueSignalInternal(NSString *signal);

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define giveSignal(signal) mck_giveSignal(signal)
#define signalGiven(signal) mck_signalGiven(signal)
#endif
