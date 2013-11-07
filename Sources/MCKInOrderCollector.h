//
//  MCKInOrderCollector.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerificationResultCollector.h"


@interface MCKInOrderCollector : NSObject <MCKVerificationResultCollector>

@end


/**
 * Verify a group of calls in order.
 */
#define mck_verifyCallsInOrder(...) mck_verifyCallGroup([[MCKInOrderCollector alloc] init], __VA_ARGS__)
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define verifyCallsInOrder(...) mck_verifyCallsInOrder(__VA_ARGS__)
#endif
