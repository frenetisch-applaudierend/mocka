//
//  RGMockReturnStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockStubAction.h"
#import "RGMockTypeEncodings.h"


@interface RGMockReturnStubAction : NSObject <RGMockStubAction>

+ (id)returnActionWithValue:(id)value;
- (id)initWithValue:(id)value;

@end


#define mock_returnValue(val) mock_record_stub_action(mock_returnValueAction(val))

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define returnValue(val) mock_returnValue(val)
#endif

#define mock_returnValueAction(val) [RGMockReturnStubAction returnActionWithValue:mock_createCenericValue(@encode(typeof(val)), val)]
id mock_createCenericValue(const char *type, ...);

