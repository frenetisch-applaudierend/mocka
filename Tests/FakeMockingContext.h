//
//  FakeMockingContext.h
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"


@interface FakeMockingContext : RGMockContext

#pragma mark - Initialization

+ (id)fakeContext;


#pragma mark - Handling the Mocking Mode

@property (nonatomic, readwrite, assign) RGMockContextMode mode;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) NSArray *handledInvocations;

- (void)handleInvocation:(NSInvocation *)invocation;

@end


@interface RGMockContext (PrivateMethods)

- (void)stubInvocation:(NSInvocation *)invocation;

@end
