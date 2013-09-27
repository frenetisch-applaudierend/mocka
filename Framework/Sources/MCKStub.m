//
//  MCKStub.m
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKStub.h"
#import "MCKStubAction.h"
#import "MCKInvocationMatcher.h"


@implementation MCKStub {
    NSMutableArray          *_invocationPrototypes;
    NSMutableArray          *_actions;
    MCKInvocationMatcher *_invocationMatcher;
}


#pragma mark - Initialization

- (id)initWithInvocationMatcher:(MCKInvocationMatcher *)invocationMatcher {
    if ((self = [super init])) {
        _invocationPrototypes = [NSMutableArray array];
        _actions = [NSMutableArray array];
        _invocationMatcher = invocationMatcher;
    }
    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use -initWithInvocationMatcher:" userInfo:nil];
}


#pragma mark - Configuration

- (void)addInvocation:(NSInvocation *)invocation withPrimitiveArgumentMatchers:(NSArray *)argumentMatchers {
    [_invocationPrototypes addObject:[[MCKStubInvocationPrototpye alloc] initWithInvocation:invocation primitiveArgumentMatchers:argumentMatchers]];
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
    for (MCKStubInvocationPrototpye *prototype in _invocationPrototypes) {
        if ([_invocationMatcher invocation:candidate matchesPrototype:prototype.invocation withPrimitiveArgumentMatchers:prototype.primitiveArgumentMatchers]) {
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


@implementation MCKStubInvocationPrototpye

- (id)initWithInvocation:(NSInvocation *)invocation primitiveArgumentMatchers:(NSArray *)argumentMatchers {
    if ((self = [super init])) {
        _invocation = invocation;
        _primitiveArgumentMatchers = [argumentMatchers copy];
    }
    return self;
}

@end
