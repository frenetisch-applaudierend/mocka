//
//  MCKStub.m
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKStub.h"
#import "MCKStubAction.h"
#import "MCKInvocationPrototype.h"


@implementation MCKStub {
    NSMutableArray *_invocationPrototypes;
    NSMutableArray *_actions;
    MCKInvocationMatcher *_invocationMatcher;
}


#pragma mark - Initialization

- (instancetype)initWithInvocationMatcher:(MCKInvocationMatcher *)invocationMatcher {
    if ((self = [super init])) {
        _invocationPrototypes = [NSMutableArray array];
        _actions = [NSMutableArray array];
        _invocationMatcher = invocationMatcher;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use -initWithInvocationMatcher:" userInfo:nil];
}


#pragma mark - Configuration

- (void)addInvocationPrototype:(MCKInvocationPrototype *)prototype {
    [_invocationPrototypes addObject:prototype];
}

- (void)addAction:(id<MCKStubAction>)action {
    [_actions addObject:action];
}

- (NSArray *)invocationPrototypes {
    return [_invocationPrototypes copy];
}

- (NSArray *)actions {
    return [_actions copy];
}


#pragma mark - Matching and Applying

- (BOOL)matchesForInvocation:(NSInvocation *)candidate {
    for (MCKInvocationPrototype *prototype in _invocationPrototypes) {
        if ([prototype matchesInvocation:candidate]) {
            return YES;
        }
    }
    return NO;
}

- (void)applyToInvocation:(NSInvocation *)invocation {
    for (id<MCKStubAction> action in _actions) {
        [action performWithInvocation:invocation];
    }
}

@end
