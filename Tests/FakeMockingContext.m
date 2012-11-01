//
//  FakeMockingContext.m
//  mocka
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "FakeMockingContext.h"
#import "MCKExceptionFailureHandler.h"


@implementation FakeMockingContext {
    NSMutableArray *_handledInvocations;
}

@synthesize mode = _fakeMode;


#pragma mark - Initialization

+ (id)fakeContext {
    return [[self alloc] init];
}

- (id)init {
    if ((self = [super init])) {
        _handledInvocations = [NSMutableArray array];
        self.failureHandler = [[MCKExceptionFailureHandler alloc] init];
    }
    return self;
}


#pragma mark - Handling Invocations

- (NSArray *)handledInvocations {
    return [_handledInvocations copy];
}

- (void)handleInvocation:(NSInvocation *)invocation {
    [_handledInvocations addObject:invocation];
}

@end
