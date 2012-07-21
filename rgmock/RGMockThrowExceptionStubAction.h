//
//  RGMockThrowExceptionStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockStubAction.h"


@interface RGMockThrowExceptionStubAction : NSObject <RGMockStubAction>

+ (id)throwExceptionActionWithException:(id)exception;
- (id)initWithException:(id)exception;

@end


#define mock_throwException(ex) mock_record_stub_action([RGMockThrowExceptionStubAction throwExceptionActionWithException:(ex)])

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define throwException(ex) mock_throwException(ex)
#endif
