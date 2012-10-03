//
//  RGMockSpy.h
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMockContext;


id mck_createSpyForObject(id object, RGMockContext *context);
BOOL mck_objectIsSpy(id object);

// Mocking Syntax
#define mck_spy(obj) mck_createSpyForObject((obj), mck_updatedContext())
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define spy(obj) mck_spy((obj))
#endif