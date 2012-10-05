//
//  RGMockVerifyNoInteractions.h
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMockContext;


// Mocking Syntax
#define mck_noMoreInteractionsOn(mock) mck_checkNoInteractions(mck_currentContext(), (mock))
#define mck_noInteractionsOn(mock) mck_noMoreInteractionsOn((mock))

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define noMoreInteractionsOn(mock) mck_noMoreInteractionsOn((mock))
#define noInteractionsOn(mock) mck_noInteractionsOn((mock))
#endif

void mck_checkNoInteractions(RGMockContext *context, id mockObject);
