//
//  MCKOrderedVerifier.h
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerifier.h"


@interface MCKOrderedVerifier : NSObject <MCKVerifier>

@property (nonatomic, assign) NSUInteger skippedInvocations;

@end


@interface MCKMockingContext (MCKOrderedVerification)

@property (nonatomic, strong) void(^inOrderBlock)(); // don't use, only for syntax reasons here

- (void)verifyInOrder:(void(^)())verifications;

@end


// Safe syntax
#define mck_inOrder [MCKMockingContext currentContext].inOrderBlock = ^()

// Nice syntax
#ifndef MOCK_DISABLE_NICE_SYNTAX
#define inOrder mck_inOrder
#endif
