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


// Mocking Syntax
static inline id mck_anyObject(void) { return mck_registerObjectMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static inline char mck_anyInt(void) { return mck_registerPrimitiveNumberMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static inline float mck_anyFloat(void) { return mck_registerPrimitiveNumberMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static inline BOOL mck_anyBool(void) { return mck_anyInt(); }
static inline char* mck_anyCString(void) { return mck_registerCStringMatcher([[MCKAnyArgumentMatcher alloc] init], MCKDefaultCStringBuffer); }
static inline SEL mck_anySelector(void) { return mck_registerSelectorMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static inline void* mck_anyPointer(void) { return mck_registerPointerMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static inline __autoreleasing id* mck_anyObjectPointer(void) { return (__autoreleasing id *)mck_registerPointerMatcher([[MCKAnyArgumentMatcher alloc] init]); }
#define mck_anyStruct(structType) mck_registerStructMatcher([[MCKAnyArgumentMatcher alloc] init], structType)


#ifndef MOCK_DISABLE_NICE_SYNTAX
static inline id anyObject(void) { return mck_anyObject(); }
static inline char anyInt(void) { return mck_anyInt(); }
static inline float anyFloat(void) { return mck_anyFloat(); }
static inline BOOL anyBool(void) { return mck_anyBool(); }
static inline char* anyCString(void) { return mck_anyCString(); }
static inline SEL anySelector(void) { return mck_anySelector(); }
static inline void* anyPointer(void) { return mck_anyPointer(); }
static inline __autoreleasing id* anyObjectPointer(void) { return mck_anyObjectPointer(); }
#define anyStruct(structType) mck_anyStruct(structType)
#endif
