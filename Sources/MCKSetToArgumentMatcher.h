//
//  MCKSetToArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 21.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKArgumentMatcher.h"


@interface MCKSetToArgumentMatcher : NSObject <MCKArgumentMatcher>

- (id)initWithObject:(id)object;

@end


// Mocking Syntax
static __autoreleasing id* mck_setTo(id object) {
    return (__autoreleasing id *)mck_registerPointerMatcher([[MCKSetToArgumentMatcher alloc] initWithObject:object]);
}

#ifndef MOCK_DISABLE_NICE_SYNTAX
static __autoreleasing id* setTo(id object) { return mck_setTo(object); }
#endif
