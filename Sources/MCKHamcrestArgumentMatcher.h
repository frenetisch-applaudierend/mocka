//
//  MCKHamcrestArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKArgumentMatcher.h"


@interface MCKHamcrestArgumentMatcher : MCKArgumentMatcher

+ (id)matcherWithHamcrestMatcher:(id)hamcrestMatcher;

@property (nonatomic, strong) id hamcrestMatcher;

@end


/**
 * A matcher that matchers using the given hamcrest matcher.
 *
 * @param TYPE    The argument type
 * @param MATCHER The hamcrest matcher to use
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_hamcrestArg(TYPE, MATCHER) MCKRegisterMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:(MATCHER)], TYPE)
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define hamcrestArg(TYPE, MATCHER) mck_hamcrestArg(TYPE, MATCHER)
#endif
