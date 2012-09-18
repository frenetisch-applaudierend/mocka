//
//  FakeVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockVerificationHandler.h"

@interface FakeVerificationHandler : NSObject <RGMockVerificationHandler>

+ (id)handlerWhichFailsWithMessage:(NSString *)message;
+ (id)handlerWhichReturns:(NSIndexSet *)indexSet isSatisfied:(BOOL)isSatisfied;

@property (nonatomic, readonly) NSUInteger numberOfCalls;

@property (nonatomic, readonly) NSInvocation *lastInvocationPrototype;
@property (nonatomic, readonly) NSArray      *lastArgumentMatchers;
@property (nonatomic, readonly) NSArray      *lastRecordedInvocations;

@end
