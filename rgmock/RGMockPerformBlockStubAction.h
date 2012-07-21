//
//  RGMockPerformBlockStubAction.h
//  rgmock
//
//  Created by Markus Gasser on 18.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockStubAction.h"


@interface RGMockPerformBlockStubAction : NSObject <RGMockStubAction>

+ (id)performBlockActionWithBlock:(void(^)(NSInvocation *inv))block;
- (id)initWithBlock:(void(^)(NSInvocation *inv))block;

@end


// Mocking Syntax
#define mock_performBlock(blk) mock_record_stub_action([RGMockPerformBlockStubAction performBlockActionWithBlock:(blk)])

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define performBlock(blk) mock_performBlock(blk)
#endif
