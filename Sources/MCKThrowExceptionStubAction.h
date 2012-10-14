//
//  MCKThrowExceptionStubAction.h
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKStubAction.h"
#import "MCKMockingContext.h"


@interface MCKThrowExceptionStubAction : NSObject <MCKStubAction>

+ (id)throwExceptionActionWithException:(id)exception;
- (id)initWithException:(id)exception;

@end


// Mocking Syntax
static void mck_throwException(NSException *exception) {
    [[MCKMockingContext currentContext] addStubAction:[MCKThrowExceptionStubAction throwExceptionActionWithException:exception]];
}

#ifndef MOCK_DISABLE_NICE_SYNTAX
static void throwException(NSException *exception) {
    mck_throwException(exception);
}
#endif
