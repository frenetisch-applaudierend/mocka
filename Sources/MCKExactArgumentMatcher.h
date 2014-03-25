//
//  MCKExactArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKArgumentMatcher.h"


@interface MCKExactArgumentMatcher : NSObject <MCKArgumentMatcher>

+ (instancetype)matcherWithArgument:(id)expected;
- (instancetype)initWithArgument:(id)expected;

@property (nonatomic, strong) id expectedArgument;

@end


#pragma mark - Mocking Syntax

/**
 * Match a signed integer argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern SInt8 mck_intArg(SInt64 arg);

/**
 * Match an unsigned integer argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern UInt8 mck_unsignedIntArg(UInt64 arg);

/**
 * Match a float argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern float mck_floatArg(float arg);

/**
 * Match a double argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern double mck_doubleArg(double arg);

/**
 * Match a BOOL argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern BOOL mck_boolArg(BOOL arg);

/**
 * Match a C string argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern char* mck_cStringArg(const char *arg);

/**
 * Match a selector argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern SEL mck_selectorArg(SEL arg);

/**
 * Match a generic pointer argument with the given value.
 *
 * @param arg The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
extern void* mck_pointerArg(const void *arg);

/**
 * Match an __autoreleasing object pointer with the given value.
 *
 * You can use this matcher e.g. for passing error objects:
 * verifyCall ([moc save:mck_objectPointerArg(&error)]);
 *
 * If you need a different qualifier than __autoreleasing
 * use mck_objectPointerArgWithQualifier() instead.
 *
 * @param ARG The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_objectPointerArg(ARG) mck_objectPointerArgWithQualifier(__autoreleaing, (ARG))

/**
 * Match any object pointer using the given qualifier.
 *
 * The qualifier is usually either __autoreleasing or __unsafe_unretained.
 *
 * You can use this matcher e.g. for getting objects by reference, e.g.:
 * verifyCall ([array getObjects:mck_objectPointerArgWithQualifier(__unsafe_unretained, &objects)]);
 *
 * If you need __autoreleasing as a qualifier, you can also use mck_objectPointerArg()
 * instead.
 *
 * @param QUALIFIER The qualifier to use (either __autoreleasing or __unsafe_unretained)
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_objectPointerArgWithQualifier(QUALIFIER, ARG) ((id QUALIFIER *)mck_pointerArg(ARG))

/**
 * Match the given struct.
 *
 * @param ARG The value to match
 * @return An internal value that represents this matcher. Never use this value yourself.
 */
#define mck_structArg(ARG) mck_registerStructMatcher(\
    [MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithBytes:(typeof(ARG)[]){ (ARG) }\
                                                  objCType:@encode(typeof(ARG))]], typeof(ARG))


#pragma mark -
#ifndef MCK_DISABLE_NICE_SYNTAX

    static inline char intArg(int64_t arg) { return mck_intArg(arg); }
    static inline char unsignedIntArg(uint64_t arg) { return mck_unsignedIntArg(arg); }
    static inline float floatArg(float arg) { return mck_floatArg(arg); }
    static inline BOOL boolArg(BOOL arg) { return mck_boolArg(arg); }
    static inline char* cStringArg(const char *arg) { return mck_cStringArg(arg); }
    static inline SEL selectorArg(SEL arg) { return mck_selectorArg(arg); }
    static inline void* pointerArg(void *arg) { return mck_pointerArg(arg); }
    #define objectPointerArg(ARG) mck_objectPointerArg(ARG)
    #define objectPointerArgWithQualifier(QUALIFIER, ARG) mck_objectPointerArgWithQualifier(QUALIFIER, ARG)
    #define structArg(arg) mck_structArg(arg)

#endif
