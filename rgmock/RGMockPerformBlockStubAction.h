//
//  RGMockPerformBlockStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockStubAction.h"
#import "RGMockContext.h"


@interface RGMockPerformBlockStubAction : NSObject <RGMockStubAction>

+ (id)performBlockActionWithBlock:(void(^)(NSInvocation *inv))block;
- (id)initWithBlock:(void(^)(NSInvocation *inv))block;

@end


// Mocking Syntax
static void mock_performBlock(void(^block)(NSInvocation *inv)) {
    [[RGMockContext currentContext] addStubAction:[RGMockPerformBlockStubAction performBlockActionWithBlock:block]];
}

#ifndef MOCK_DISABLE_NICE_SYNTAX
static void performBlock(void(^block)(NSInvocation *inv)) {
    mock_performBlock(block);
}
#endif
