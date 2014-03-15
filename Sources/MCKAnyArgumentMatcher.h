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
 * Matcher that matches any object.
 */
extern id mck_anyObject(void);

/**
 * Matcher that matches any integer.
 */
extern UInt8 mck_anyInt(void);

/**
 * Matcher that matches any float or double.
 */
extern float mck_anyFloat(void);

/**
 * Matcher that matches any boolean.
 */
extern BOOL mck_anyBool(void);

/**
 * Matcher that matches any C string.
 */
extern char* mck_anyCString(void);

/**
 * Matcher that matches any Objective-C selector.
 */
extern SEL mck_anySelector(void);

/**
 * Matcher that matches any generic pointer.
 */
extern void* mck_anyPointer(void);

/**
 * Matcher that matches any __autoreleasing object pointer.
 *
 * You can use this matcher e.g. for passing error objects:
 * verifyCall ([moc save:mck_anyObjectPointer()]);
 *
 * If you need a different qualifier than __autoreleasing
 * use mck_anyObjectPointerOfType() instead.
 */
#define mck_anyObjectPointer() mck_anyObjectPointerWithQualifier(__autoreleasing)

/**
 * Matcher that matches any object pointer using the given qualifier.
 *
 * The qualifier is usually either __autoreleasing or __unsafe_unretained.
 *
 * You can use this matcher e.g. for getting objects by reference, e.g.:
 * verifyCall ([array getObjects:mck_anyObjectPointerWithQualifier(__unsafe_unretained)]);
 *
 * If you need __autoreleasing as a qualifier, you can also use mck_anyObjectPointer()
 * instead.
 *
 * @param QUALIFIER The qualifier to use (either __autoreleasing or __unsafe_unretained)
 */
#define mck_anyObjectPointerWithQualifier(QUALIFIER) ((id QUALIFIER *)mck_anyPointer())

/**
 * Matcher that matches any struct of the given type.
 *
 * @param STRT_TYPE The name of the struct type which should be passed.
 */
#define mck_anyStruct(STRT_TYPE) mck_registerStructMatcher([[MCKAnyArgumentMatcher alloc] init], STRT_TYPE)


#ifndef MCK_DISABLE_NICE_SYNTAX

    static inline id anyObject(void) { return mck_anyObject(); }
    static inline char anyInt(void) { return mck_anyInt(); }
    static inline float anyFloat(void) { return mck_anyFloat(); }
    static inline BOOL anyBool(void) { return mck_anyBool(); }
    static inline char* anyCString(void) { return mck_anyCString(); }
    static inline SEL anySelector(void) { return mck_anySelector(); }
    static inline void* anyPointer(void) { return mck_anyPointer(); }

    #define anyObjectPointer() mck_anyObjectPointer()
    #define anyObjectPointerWithQualifier(QUALIFIER) mck_anyObjectPointerWithQualifier(QUALIFIER)
    #define anyStruct(structType) mck_anyStruct(structType)

#endif
