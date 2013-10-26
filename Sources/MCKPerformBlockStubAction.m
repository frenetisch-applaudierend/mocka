//
//  MCKPerformBlockStubAction.m
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKPerformBlockStubAction.h"

@implementation MCKPerformBlockStubAction {
    void(^_block)(NSInvocation *inv);
}

#pragma mark - Initialization

+ (id)performBlockActionWithBlock:(void(^)(NSInvocation *inv))block {
    return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(void(^)(NSInvocation *inv))block {
    if ((self = [super init])) {
        _block = [block copy];
    }
    return self;
}


#pragma mark - Performing the Action

- (void)performWithInvocation:(NSInvocation *)invocation {
    if (_block != nil) {
        _block(invocation);
    }
}

@end


#pragma mark - Mocking Syntax

void mck_performBlock(void(^block)(NSInvocation *inv)) {
    _mck_addStubAction([MCKPerformBlockStubAction performBlockActionWithBlock:block]);
}

#ifndef MCK_DISABLE_NICE_SYNTAX

    void performBlock(void(^block)(NSInvocation *inv)) {
        mck_performBlock(block);
    }

#endif
