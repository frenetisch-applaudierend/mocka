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
static id mck_anyObject(void) { return mck_registerObjectMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static char mck_anyInt(void) { return mck_registerPrimitiveNumberMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static float mck_anyFloat(void) { return mck_registerPrimitiveNumberMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static BOOL mck_anyBool(void) { return mck_anyInt(); }
static char* mck_anyCString(void) { return mck_registerCStringMatcher([[MCKAnyArgumentMatcher alloc] init], MCKDefaultCStringBuffer); }
static SEL mck_anySelector(void) { return mck_registerSelectorMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static void* mck_anyPointer(void) { return mck_registerPointerMatcher([[MCKAnyArgumentMatcher alloc] init]); }
static __autoreleasing id* mck_anyObjectPointer(void) { return (__autoreleasing id *)mck_registerPointerMatcher([[MCKAnyArgumentMatcher alloc] init]); }
#define mck_anyStruct(structType) mck_registerStructMatcher([[MCKAnyArgumentMatcher alloc] init], structType)


#ifndef MOCK_DISABLE_NICE_SYNTAX
static id anyObject(void) { return mck_anyObject(); }
static char anyInt(void) { return mck_anyInt(); }
static float anyFloat(void) { return mck_anyFloat(); }
static BOOL anyBool(void) { return mck_anyBool(); }
static char* anyCString(void) { return mck_anyCString(); }
static SEL anySelector(void) { return mck_anySelector(); }
static void* anyPointer(void) { return mck_anyPointer(); }
static __autoreleasing id* anyObjectPointer(void) { return mck_anyObjectPointer(); }
#define anyStruct(structType) mck_anyStruct(structType)
#endif