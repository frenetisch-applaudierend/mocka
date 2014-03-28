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


#define mck_inOrder mck_matchGroup([[MCKInOrderCollector alloc] init])
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define inOrder mck_inOrder
#endif


/**
 * Verify a group of calls in order.
 */
#define mck_verifyInOrder mck_verifyUsingCollector([[MCKInOrderCollector alloc] init])
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define verifyInOrder mck_verifyInOrder
#endif
