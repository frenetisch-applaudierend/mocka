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

+ (id)fakeContext;


#pragma mark - Handling the Mocking Mode

@property (nonatomic, readwrite, assign) MCKContextMode mode;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) NSArray *handledInvocations;

- (void)handleInvocation:(NSInvocation *)invocation;

@end


@interface MCKMockingContext (PrivateMethods)

- (void)stubInvocation:(NSInvocation *)invocation;

@end
