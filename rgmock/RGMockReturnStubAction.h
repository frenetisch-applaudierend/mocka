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

+ (id)returnActionWithValue:(NSValue *)value;
- (id)initWithValue:(NSValue *)value;

@end


#define mock_genericValue(val) (val == 0 || !isPrimitiveType(@encode(typeof(val))) ? nil : \
    [[NSNumber alloc] initWithBytes:&(typeof(val)){(val)} objCType:@encode(typeof(val))])

#define mock_returnValue(val) mock_record_stub_action([RGMockReturnStubAction returnActionWithValue:mock_genericValue(val)])

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define returnValue(val) mock_returnValue(val)
#endif
