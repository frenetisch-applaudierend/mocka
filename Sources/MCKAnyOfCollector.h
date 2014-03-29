//
//  MCKAnyOfCollector.h
//  mocka
//
//  Created by Markus Gasser on 29.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerificationResultCollector.h"


@interface MCKAnyOfCollector : NSObject <MCKVerificationResultCollector>

@end


/**
 * Match a group of calls in a given order.
 */
#define mck_matchAnyOf mck_matchGroup([[MCKAnyOfCollector alloc] init])
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define matchAnyOf mck_matchAnyOf
#endif
