//
//  MCKExactArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKArgumentMatcher.h"


@interface MCKExactArgumentMatcher : MCKArgumentMatcher

+ (instancetype)matcherWithArgument:(id)expected;
- (instancetype)initWithArgument:(id)expected;

@property (nonatomic, strong) id expectedArgument;

@end


#pragma mark - Mocking Syntax

/**
 * Match the exact given value.
 *
 * This matcher is mainly useful to pass arguments in methods where you already used primitive
 * matchers and therefore must pass all primitive arguments as matchers.
 *
 * @param ARG The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_exactArg(ARG) MCKRegisterMatcher(_MCKCreateExactMatcher(ARG), typeof(ARG))
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define exactArg(ARG) mck_exactArg(ARG)
#endif


#pragma mark - Internal

#define _MCKCreateExactMatcher(ARG) _MCKCreateExactMatcherFromBytesAndType(((typeof(ARG)[]){ (ARG) }), @encode(typeof(ARG)))
extern MCKExactArgumentMatcher* _MCKCreateExactMatcherFromBytesAndType(const void *bytes, const char *type);
