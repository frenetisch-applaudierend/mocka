//
//  MCKThrowExceptionStubAction.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKThrowExceptionStubAction.h"

@implementation MCKThrowExceptionStubAction {
    id _exception;
}

#pragma mark - Initialization

+ (id)throwExceptionActionWithException:(id)exception {
    return [[self alloc] initWithException:exception];
}

- (id)initWithException:(id)exception {
    if ((self = [super init])) {
        _exception = exception;
    }
    return self;
}


#pragma mark - Performing the Action

- (void)performWithInvocation:(NSInvocation *)invocation {
    @throw _exception;
}

@end


#pragma mark - Mocking Syntax

void mck_throwException(NSException *exception) {
    _mck_addStubAction([MCKThrowExceptionStubAction throwExceptionActionWithException:exception]);
}

void mck_throwNewException(NSString *name, NSString *reason, NSDictionary *userInfo) {
    mck_throwException([NSException exceptionWithName:name reason:reason userInfo:userInfo]);
}


#ifndef MOCK_DISABLE_NICE_SYNTAX

    void throwException(NSException *exception) {
        mck_throwException(exception);
    }

    void throwNewException(NSString *name, NSString *reason, NSDictionary *userInfo) {
        mck_throwNewException(name, reason, userInfo);
    }

#endif
