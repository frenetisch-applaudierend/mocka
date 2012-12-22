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

@property (nonatomic, strong) id expectedArgument;

+ (id)matcherWithArgument:(id)expected;

@end


// Mocking Syntax
static char mck_intArg(int64_t arg) { return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]); }
static char mck_unsignedIntArg(uint64_t arg) { return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]); }
static float mck_floatArg(float arg) { return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]); }
static BOOL mck_boolArg(BOOL arg) { return mck_registerPrimitiveNumberMatcher([MCKExactArgumentMatcher matcherWithArgument:@(arg)]); }

static char* mck_cStringArg(const char *arg) {
    return mck_registerCStringMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]], MCKDefaultCStringBuffer);
}

static SEL mck_selectorArg(SEL arg) {
    return mck_registerSelectorMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]]);
}

static void* mck_pointerArg(void *arg) {
    return mck_registerPointerMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]]);
}

static __autoreleasing id* mck_objectPointerArg(id *arg) {
    return (__autoreleasing id *)mck_registerPointerMatcher([MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithPointer:arg]]);
}

#define mck_structArg(arg) mck_registerStructMatcher(\
    [MCKExactArgumentMatcher matcherWithArgument:[NSValue valueWithBytes:(typeof(arg)[]){ (arg) } objCType:@encode(typeof(arg))]], typeof(arg)\
)


#ifndef MOCK_DISABLE_NICE_SYNTAX
static char intArg(int64_t arg) { return mck_intArg(arg); }
static char unsignedIntArg(uint64_t arg) { return mck_unsignedIntArg(arg); }
static float floatArg(float arg) { return mck_floatArg(arg); }
static BOOL boolArg(BOOL arg) { return mck_boolArg(arg); }
static char* cStringArg(const char *arg) { return mck_cStringArg(arg); }
static SEL selectorArg(SEL arg) { return mck_selectorArg(arg); }
static void* pointerArg(void *arg) { return mck_pointerArg(arg); }
static __autoreleasing id* objectPointerArg(id *arg) { return mck_objectPointerArg(arg); }
#define structArg(arg) mck_structArg(arg)
#endif