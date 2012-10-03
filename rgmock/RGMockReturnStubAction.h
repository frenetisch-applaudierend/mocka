//
//  RGMockReturnStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockStubAction.h"


@interface RGMockReturnStubAction : NSObject <RGMockStubAction>

+ (id)returnActionWithValue:(id)value;
- (id)initWithValue:(id)value;

@end


// Mocking Syntax
#define mck_returnValue(val) [[RGMockContext currentContext] addStubAction:mck_returnValueAction(val)]
#define mck_returnStruct(strt) [[RGMockContext currentContext] addStubAction:mck_returnStructAction(strt)]

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define returnValue(val) mck_returnValue(val)
#define returnStruct(val) mck_returnStruct(val)
#endif

#define mck_returnValueAction(val) [RGMockReturnStubAction returnActionWithValue:mck_createGenericValue(@encode(typeof(val)), val)]
#define mck_returnStructAction(strt) [RGMockReturnStubAction returnActionWithValue:[NSValue valueWithBytes:&strt objCType:@encode(typeof(strt))]]
id mck_createGenericValue(const char *type, ...);

