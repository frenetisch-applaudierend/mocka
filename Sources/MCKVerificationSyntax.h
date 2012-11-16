//
//  MCKVerificationSyntax.h
//  mocka
//
//  Created by Markus Gasser on 07.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKMockingContext.h"


// Safe syntax
#define mck_verify [mck_updatedContext() updateContextMode:MCKContextModeVerifying];
#define mck_inOrder mck_updatedContext().inOrderBlock = ^()


// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#undef verify // under Mac OS X this macro defined already (in /usr/include/AssertMacros.h)
#define verify mck_verify
#define inOrder mck_inOrder
#endif
