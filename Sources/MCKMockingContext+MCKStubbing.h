//
//  MCKMockingContext+MCKStubbing.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext.h"


@interface MCKMockingContext (MCKStubbing)

@property (nonatomic, readonly) MCKStub *activeStub;

- (void)beginStubbing;
- (void)endStubbing;

- (void)stubInvocation:(NSInvocation *)invocation;
- (BOOL)isInvocationStubbed:(NSInvocation *)invocation;

@end
