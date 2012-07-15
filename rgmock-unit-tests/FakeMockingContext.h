//
//  FakeMockingContext.h
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface FakeMockingContext : NSObject

#pragma mark - Initialization

+ (id)fakeContext;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) NSArray *handledInvocations;

- (void)handleInvocation:(NSInvocation *)invocation;

@end
