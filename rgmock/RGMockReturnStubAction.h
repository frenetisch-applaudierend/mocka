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


// Mocking Syntax
#define mock_returnValue(val) mock_record_stub_action(mock_returnValueAction(val))
#define mock_returnStruct(strt) mock_record_stub_action(mock_returnStructAction(strt))

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define returnValue(val) mock_returnValue(val)
#define returnStruct(val) mock_returnStruct(val)
#endif

#define mock_returnValueAction(val) [RGMockReturnStubAction returnActionWithValue:mock_createGenericValue(@encode(typeof(val)), val)]
#define mock_returnStructAction(strt) [RGMockReturnStubAction returnActionWithValue:[NSValue valueWithBytes:&strt objCType:@encode(typeof(strt))]]
id mock_createGenericValue(const char *type, ...);

