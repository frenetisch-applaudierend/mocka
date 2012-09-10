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
#define mock_noMoreInteractionsOn(mock) mock_checkNoInteractions(mock_updatedContext(), (mock))
#define mock_noInteractionsOn(mock) mock_noMoreInteractionsOn((mock))

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define noMoreInteractionsOn(mock) mock_noMoreInteractionsOn((mock))
#define noInteractionsOn(mock) mock_noInteractionsOn((mock))
#endif

void mock_checkNoInteractions(RGMockContext *context, id mockObject);
