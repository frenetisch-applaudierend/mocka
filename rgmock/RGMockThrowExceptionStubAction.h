//
//  RGMockThrowExceptionStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockStubAction.h"
#import "RGMockContext.h"


@interface RGMockThrowExceptionStubAction : NSObject <RGMockStubAction>

+ (id)throwExceptionActionWithException:(id)exception;
- (id)initWithException:(id)exception;

@end


// Mocking Syntax
static void mck_throwException(NSException *exception) {
    [[RGMockContext currentContext] addStubAction:[RGMockThrowExceptionStubAction throwExceptionActionWithException:exception]];
}

#ifndef MOCK_DISABLE_NICE_SYNTAX
static void throwException(NSException *exception) {
    mck_throwException(exception);
}
#endif
