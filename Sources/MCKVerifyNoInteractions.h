//
//  MCKVerifyNoInteractions.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


// Mocking Syntax
#define mck_verifyNoMoreInteractionsOn(MOCK) _MCKCheckNoInteractions(MOCK)
#define mck_verifyNoInteractionsOn(MOCK)     _MCKCheckNoInteractions(MOCK)

#ifndef MCK_DISABLE_NICE_SYNTAX

    #define verifyNoMoreInteractionsOn(MOCK) mck_verifyNoMoreInteractionsOn(MOCK)
    #define verifyNoInteractionsOn(MOCK)     mck_verifyNoInteractionsOn(MOCK)

#endif

extern void _MCKCheckNoInteractions(id mockObject);
