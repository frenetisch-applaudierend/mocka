//
//  RGClassMock.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

@class RGMockingContext;


@interface RGClassMock : NSObject

+ (id)mockForClass:(Class)cls context:(RGMockingContext *)context;

@end


// Mocking Syntax

#define mock_classMock(cls) [RGClassMock mockForClass:(cls) context:mock_current_context()];

#ifdef MOCK_SHORTHAND // Nice syntax
    #define classMock(cls) mock_classMock((cls))
#endif
