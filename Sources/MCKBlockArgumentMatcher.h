//
//  MCKBlockArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKArgumentMatcher.h"
#import "MCKValueSerialization.h"


@interface MCKBlockArgumentMatcher : NSObject <MCKArgumentMatcher>

+ (instancetype)matcherWithBlock:(BOOL(^)(NSValue *serialized))block;
- (instancetype)initWithBlock:(BOOL(^)(NSValue *serialized))block;

@property (nonatomic, copy) BOOL(^matcherBlock)(NSValue *serialized);

@end


#pragma mark - Mocking Syntax

/**
 * Match an argument using the given block.
 *
 * @param TYPE  The type of the argument
 * @param BLOCK The block to match with
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_argMatching(TYPE, BLOCK) MCKRegisterMatcher(_MCKCreateBlockMatcher(TYPE, (BLOCK)), TYPE)
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define argMatching(TYPE, BLOCK) mck_argMatching(TYPE, BLOCK)
#endif


#pragma mark - Internal

#define _MCKCreateBlockMatcher(TYPE, BLOCK) [MCKBlockArgumentMatcher matcherWithBlock:^BOOL(NSValue *serialized) {\
    return BLOCK(MCKDeserializeValue(serialized, TYPE));\
}]
