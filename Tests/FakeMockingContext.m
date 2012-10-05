//
//  FakeMockingContext.m
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "FakeMockingContext.h"


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
    }
    return self;
}


#pragma mark - Handling Failures

- (void)failWithReason:(NSString *)reason {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

#pragma mark - Handling Invocations

- (NSArray *)handledInvocations {
    return [_handledInvocations copy];
}

- (void)handleInvocation:(NSInvocation *)invocation {
    [_handledInvocations addObject:invocation];
}

@end