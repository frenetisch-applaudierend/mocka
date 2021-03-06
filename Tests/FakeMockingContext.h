//
//  FakeMockingContext.h
//  mocka
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"


@interface FakeMockingContext : MCKMockingContext

#pragma mark - Initialization

+ (instancetype)fakeContext;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) NSArray *handledInvocations;

- (void)handleInvocation:(NSInvocation *)invocation;


#pragma mark - Handling Failures

@property (nonatomic, assign) BOOL shouldIgnoreFailures;

@end


@interface MCKMockingContext (MCKMockingContextPrivate)

- (void)updateContextMode:(MCKContextMode)newMode;
- (void)stubInvocation:(NSInvocation *)invocation;

@end
