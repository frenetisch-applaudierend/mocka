//
//  MCKReturnStubAction.h
//  mocka
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKStubAction.h"


@interface MCKReturnStubAction : NSObject <MCKStubAction>

+ (id)returnActionWithValue:(id)value;
- (id)initWithValue:(id)value;

@property (nonatomic, readonly) id returnValue;

@end


// Mocking Syntax
#define mck_returnValue(...) _mck_addStubAction(_mck_returnValueAction((__VA_ARGS__)))
#define mck_returnStruct(...) _mck_addStubAction(_mck_returnStructAction((__VA_ARGS__)))

#ifndef MOCK_DISABLE_NICE_SYNTAX

    #define returnValue(...) mck_returnValue((__VA_ARGS__))
    #define returnStruct(...) mck_returnStruct((__VA_ARGS__))

#endif


// Internal
#define _mck_returnValueAction(val) \
    [MCKReturnStubAction returnActionWithValue:_mck_createGenericValue(@encode(typeof(val)), val)]
#define _mck_returnStructAction(strt) \
    [MCKReturnStubAction returnActionWithValue:[NSValue valueWithBytes:(typeof(strt)[]){ strt } objCType:@encode(typeof(strt))]]

extern id _mck_createGenericValue(const char *type, ...);
