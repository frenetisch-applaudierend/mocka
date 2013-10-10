//
//  MCKPerformBlockStubAction.h
//  mocka
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKStubAction.h"


@interface MCKPerformBlockStubAction : NSObject <MCKStubAction>

+ (id)performBlockActionWithBlock:(void(^)(NSInvocation *inv))block;
- (id)initWithBlock:(void(^)(NSInvocation *inv))block;

@end


// Mocking Syntax
extern void mck_performBlock(void(^block)(NSInvocation *inv));

#ifndef MOCK_DISABLE_NICE_SYNTAX

    extern void performBlock(void(^block)(NSInvocation *inv));

#endif
