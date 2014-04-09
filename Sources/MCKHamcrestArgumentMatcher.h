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

@property (nonatomic, strong) id hamcrestMatcher;

+ (id)matcherWithHamcrestMatcher:(id)hamcrestMatcher;

@end

// Mocking Syntax
static inline char mck_intArgThat(id matcher) { return MCKRegisterMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher], char); }
static inline float mck_floatArgThat(id matcher) { return MCKRegisterMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher], float); }
static inline double mck_doubleArgThat(id matcher) { return MCKRegisterMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher], double); }
static inline BOOL mck_boolArgThat(id matcher) { return MCKRegisterMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher], BOOL); }


#ifndef MCK_DISABLE_NICE_SYNTAX
static inline char intArgThat(id matcher) { return mck_intArgThat(matcher); }
static inline float floatArgThat(id matcher) { return mck_floatArgThat(matcher); }
static inline double doubleArgThat(id matcher) { return mck_doubleArgThat(matcher); }
static inline BOOL boolArgThat(id matcher) { return mck_boolArgThat(matcher); }
#endif
