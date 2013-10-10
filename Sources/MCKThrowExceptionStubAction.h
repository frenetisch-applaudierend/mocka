//
//  MCKThrowExceptionStubAction.h
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKStubAction.h"


@interface MCKThrowExceptionStubAction : NSObject <MCKStubAction>

+ (id)throwExceptionActionWithException:(id)exception;
- (id)initWithException:(id)exception;

@end


// Mocking Syntax
extern void mck_throwException(NSException *exception);
extern void mck_throwNewException(NSString *name, NSString *reason, NSDictionary *userInfo);

#ifndef MOCK_DISABLE_NICE_SYNTAX

    extern void throwException(NSException *exception);
    extern void throwNewException(NSString *name, NSString *reason, NSDictionary *userInfo);

#endif
