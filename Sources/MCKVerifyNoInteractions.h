//
//  MCKVerifyNoInteractions.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


// Mocking Syntax
#define mck_matchNoMoreInteractionsOn(MOCK) _MCKCheckNoInteractions(MOCK)
#define mck_matchNoInteractionsOn(MOCK)     _MCKCheckNoInteractions(MOCK)

#ifndef MCK_DISABLE_NICE_SYNTAX

    #define matchNoMoreInteractionsOn(MOCK) mck_matchNoMoreInteractionsOn(MOCK)
    #define matchNoInteractionsOn(MOCK)     mck_matchNoInteractionsOn(MOCK)

#endif

extern void _MCKCheckNoInteractions(id mockObject);
