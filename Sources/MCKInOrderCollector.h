//
//  MCKInOrderCollector.h
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mocka/MCKVerificationResultCollector.h>


@interface MCKInOrderCollector : NSObject <MCKVerificationResultCollector>

@end


// safe syntax
#define mck_inOrder mck_beginVerifyGroupCallsUsingCollector([[MCKInOrderCollector alloc] init])

// nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX

    #define inOrder mck_inOrder

#endif
