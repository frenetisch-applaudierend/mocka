//
//  MCKVerifyNoInteractions.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


// Mocking Syntax
#define mck_noMoreInteractionsOn(mock) mck_checkNoInteractions(self, (mock))
#define mck_noInteractionsOn(mock) mck_noMoreInteractionsOn((mock))

#ifndef MCK_DISABLE_NICE_SYNTAX
#define noMoreInteractionsOn(mock) mck_noMoreInteractionsOn((mock))
#define noInteractionsOn(mock) mck_noInteractionsOn((mock))
#endif

extern void mck_checkNoInteractions(id testCase, id mockObject);
