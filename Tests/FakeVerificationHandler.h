//
//  FakeVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKVerificationHandler.h"


@interface FakeVerificationHandler : NSObject <MCKVerificationHandler>

+ (instancetype)dummy;

+ (instancetype)handlerWhichSucceeds;
+ (instancetype)handlerWhichSucceedsWithMatches:(NSIndexSet *)matches;
+ (instancetype)handlerWhichFailsWithMatches:(NSIndexSet *)matches reason:(NSString *)reason;
+ (instancetype)handlerWhichFailsWithReason:(NSString *)reason;

+ (instancetype)handlerWithResult:(MCKVerificationResult *)result;
+ (instancetype)handlerWithImplementation:(MCKVerificationResult*(^)(MCKInvocationPrototype*, NSArray*))implementation;

@property (nonatomic, readonly) MCKVerificationResult*(^implementation)(MCKInvocationPrototype*, NSArray*);
@property (nonatomic, readonly) MCKVerificationResult *result;
@property (nonatomic, readonly) NSArray *calls; // instances of FakeVerificationHandlerCall
@property (nonatomic, assign) BOOL mustAwaitTimeoutForFailure;
@property (nonatomic, assign) BOOL failsFastDuringTimeout;

@end


@interface FakeVerificationHandlerCall : NSObject

+ (instancetype)callWithPrototype:(MCKInvocationPrototype *)prototype
                      invocations:(NSArray *)invocations
                           result:(MCKVerificationResult *)result;

@property (nonatomic, readonly) MCKInvocationPrototype *prototype;
@property (nonatomic, readonly) NSArray *invocations;
@property (nonatomic, readonly) MCKVerificationResult *result;

@end
