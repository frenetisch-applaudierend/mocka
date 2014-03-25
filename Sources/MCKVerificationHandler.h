//
//  MCKVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerificationResult.h"
#import "MCKInvocationPrototype.h"


@protocol MCKVerificationHandler <NSObject>

- (MCKVerificationResult *)verifyInvocations:(NSArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype;

/**
 * Specify wether the timeout must be awaited in order to determine the validity of the result.
 *
 * If this method returns YES, then the result will be discarded and checking
 * is retried until the timeout has expired.
 *
 * This is useful for example to implement a handler that checks for a certain
 * number of invocations. Until the timeout has expired you cannot be sure that
 * there won't be any more invocations, so you must await the timeout for
 * a successful result.
 */
- (BOOL)mustAwaitTimeoutForResult:(MCKVerificationResult *)result;

@end


extern void _mck_useVerificationHandlerImpl(id<MCKVerificationHandler> handler);
#define _mck_useVerificationHandler(HANDLER) _mck_useVerificationHandlerImpl(HANDLER),
