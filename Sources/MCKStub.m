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
#import "MCKBlockWrapper.h"


@implementation MCKStub {
    NSMutableArray *_invocationPrototypes;
    NSMutableArray *_actions;
}


#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _invocationPrototypes = [NSMutableArray array];
        _actions = [NSMutableArray array];
    }
    return self;
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
    if (self.stubBlock != nil) {
        [self applyStubBlockToInvocation:invocation];
    }
    
    for (id<MCKStubAction> action in _actions) {
        [action performWithInvocation:invocation];
    }
}

- (void)applyStubBlockToInvocation:(NSInvocation *)invocation {
    MCKBlockWrapper *block = [MCKBlockWrapper wrapperForBlock:self.stubBlock];
    [self copyArgumentsFromInvocation:invocation toBlock:block];
    [block invoke];
    
    NSAssert(invocation.methodSignature.methodReturnLength == block.blockSignature.methodReturnLength,
             @"Method return lengths don't match");
    
    if (invocation.methodSignature.methodReturnLength > 0) {
        void *returnValueHolder = malloc(invocation.methodSignature.methodReturnLength);
        [block getReturnValue:returnValueHolder];
        [invocation setReturnValue:returnValueHolder];
        free(returnValueHolder);
    }
}

- (void)copyArgumentsFromInvocation:(NSInvocation *)invocation toBlock:(MCKBlockWrapper *)block {
    if (block.blockSignature.numberOfArguments == 1) {
        return; // block has no arguments
    }
    
    if (invocation.methodSignature.numberOfArguments == (block.blockSignature.numberOfArguments + 1)) {
        // block has the same argument count as the methods arguments, does not include self and _cmd
        void *argValueHolder = malloc(invocation.methodSignature.frameLength); // max length for any argument
        for (NSUInteger arg = 2; arg < invocation.methodSignature.numberOfArguments; arg++) {
            [invocation getArgument:argValueHolder atIndex:arg];
            [block setParameter:argValueHolder atIndex:(arg - 2)];
        }
        free(argValueHolder);
    } else if (invocation.methodSignature.numberOfArguments == (block.blockSignature.numberOfArguments - 1)) {
        // block has the same argument count as the methods arguments, includes self and _cmd
        void *argValueHolder = malloc(invocation.methodSignature.frameLength); // max length for any argument
        for (NSUInteger arg = 0; arg < invocation.methodSignature.numberOfArguments; arg++) {
            [invocation getArgument:argValueHolder atIndex:arg];
            [block setParameter:argValueHolder atIndex:arg];
        }
        free(argValueHolder);
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Incompatible block type" userInfo:nil];
    }
}

@end
