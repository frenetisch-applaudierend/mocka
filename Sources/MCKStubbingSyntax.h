//
//  MCKStubbingSyntax.h
//  mocka
//
//  Created by Markus Gasser on 07.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKMockingContext.h"


// Safe syntax
#define mck_whenCalling [mck_updatedContext() updateContextMode:MCKContextModeStubbing];
#define mck_orCalling   ; mck_whenCalling
#define mck_givenCallTo mck_whenCalling
#define mck_orCallTo    mck_orCalling
#define mck_thenDo ;
#define mck_andDo  mck_thenDo


// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define whenCalling mck_whenCalling
#define orCalling   mck_orCalling
#define givenCallTo mck_givenCallTo
#define orCallTo    mck_orCallTo
#define thenDo mck_thenDo
#define andDo  mck_andDo
#endif
