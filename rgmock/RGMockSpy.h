//
//  RGMockSpy.h
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RGMockContext;


id mock_createSpyForObject(id object, RGMockContext *context);
BOOL mock_objectIsSpy(id object);

// Mocking Syntax
#define mock_spy(obj) mock_createSpyForObject((obj), mock_currentContext())
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define spy(obj) mock_spy((obj))
#endif