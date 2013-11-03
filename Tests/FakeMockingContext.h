//
//  FakeMockingContext.h
//  mocka
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"

#import "MCKMockingContext+MCKStubbing.h"
#import "MCKMockingContext+MCKVerification.h"


@interface FakeMockingContext : MCKMockingContext

#pragma mark - Initialization

+ (instancetype)fakeContext;


#pragma mark - Handling Invocations

@property (nonatomic, readonly) NSArray *handledInvocations;

- (void)handleInvocation:(NSInvocation *)invocation;


#pragma mark - Verification Helpers

@property (nonatomic, readonly) NSUInteger verificationSuspendCount;
@property (nonatomic, readonly) NSUInteger verificationResumeCount;

@end


@interface MCKMockingContext (MCKMockingContextPrivate)

- (void)updateContextMode:(MCKContextMode)newMode;
- (void)stubInvocation:(NSInvocation *)invocation;

@end
