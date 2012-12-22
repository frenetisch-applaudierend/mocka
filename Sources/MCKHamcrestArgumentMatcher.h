//
//  MCKHamcrestArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKArgumentMatcher.h"


@interface MCKHamcrestArgumentMatcher : NSObject <MCKArgumentMatcher>

@property (nonatomic, strong) id hamcrestMatcher;

+ (id)matcherWithHamcrestMatcher:(id)hamcrestMatcher;

@end

// Mocking Syntax
static char mck_intArgThat(id matcher) { return mck_registerPrimitiveNumberMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher]); }
static float mck_floatArgThat(id matcher) { return mck_registerPrimitiveNumberMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher]); }
static double mck_doubleArgThat(id matcher) { return mck_registerPrimitiveNumberMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher]); }
static float mck_boolArgThat(id matcher) { return mck_registerPrimitiveNumberMatcher([MCKHamcrestArgumentMatcher matcherWithHamcrestMatcher:matcher]); }


#ifndef MOCK_DISABLE_NICE_SYNTAX
static char intArgThat(id matcher) { return mck_intArgThat(matcher); }
static float floatArgThat(id matcher) { return mck_floatArgThat(matcher); }
static double doubleArgThat(id matcher) { return mck_doubleArgThat(matcher); }
static BOOL boolArgThat(id matcher) { return mck_boolArgThat(matcher); }
#endif
