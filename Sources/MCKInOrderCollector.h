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
 * Match a group of calls in a given order.
 */
#define mck_matchInOrder mck_matchGroup([[MCKInOrderCollector alloc] init])
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define matchInOrder mck_matchInOrder
#endif
