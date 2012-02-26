//
//  RGMockSyntax.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"


id mock_classMock(Class cls);
id mock_spy(id<NSObject> object);

id mock_verify(RGMockContext *context, id mock);

#define mock_ctx() [RGMockContext contextWithFileName:__FILE__ lineNumber:__LINE__]
