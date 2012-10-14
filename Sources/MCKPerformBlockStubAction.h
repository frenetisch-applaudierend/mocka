//
//  MCKPerformBlockStubAction.h
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKStubAction.h"
#import "MCKMockingContext.h"


@interface MCKPerformBlockStubAction : NSObject <MCKStubAction>

+ (id)performBlockActionWithBlock:(void(^)(NSInvocation *inv))block;
- (id)initWithBlock:(void(^)(NSInvocation *inv))block;

@end


// Mocking Syntax
static void mck_performBlock(void(^block)(NSInvocation *inv)) {
    [[MCKMockingContext currentContext] addStubAction:[MCKPerformBlockStubAction performBlockActionWithBlock:block]];
}

#ifndef MOCK_DISABLE_NICE_SYNTAX
static void performBlock(void(^block)(NSInvocation *inv)) {
    mck_performBlock(block);
}
#endif
