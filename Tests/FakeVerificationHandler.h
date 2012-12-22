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

+ (id)handlerWhichFailsWithMessage:(NSString *)message;
+ (id)handlerWhichReturns:(NSIndexSet *)indexSet isSatisfied:(BOOL)isSatisfied;

@property (nonatomic, readonly) NSUInteger numberOfCalls;

@property (nonatomic, readonly) NSInvocation *lastInvocationPrototype;
@property (nonatomic, readonly) NSArray      *lastArgumentMatchers;
@property (nonatomic, readonly) NSArray      *lastRecordedInvocations;

@end
