//
//  MCKVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerificationSyntax.h"
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


#pragma mark - Counting Helpers

/**
 * Use this macro to define parmeters taking a "count".
 * This allows the user to write e.g. exactly(3 times)
 */
#define _MCKCount(COUNT) [@COUNT]

#define mck_times integerValue
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define times mck_times
#endif
