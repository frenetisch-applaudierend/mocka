//
//  MCKAnyArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKArgumentMatcher.h"


@interface MCKAnyArgumentMatcher : NSObject <MCKArgumentMatcher>
@end


#pragma mark - Mocking Syntax

/**
 * Match any value of the given type.
 *
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_any(T) MCKRegisterMatcher([[MCKAnyArgumentMatcher alloc] init], T)
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define any(T) mck_any(T)
#endif


/**
 * Match any __autoreleasing object pointer.
 *
 * You can use this matcher e.g. for passing error objects:
 * match ([moc save:mck_anyObjectPointer()]);
 *
 * This is a shorthand for mck_any(id __autoreleasing *). If you need a different qualifier
 * than __autoreleasing use mck_any(...) instead.
 *
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_anyObjectPointer() mck_any(id __autoreleasing *)
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define anyObjectPointer() mck_anyObjectPointer()
#endif
