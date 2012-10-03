//
//  RGMockAnyArgumentMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockArgumentMatcher.h"


@interface RGMockAnyArgumentMatcher : NSObject <RGMockArgumentMatcher>

@end


// Mocking Syntax
static char mck_anyInt(void) { return mck_registerPrimitiveMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static char mck_anyBool(void) { return mck_anyInt(); }
static id mck_anyObject(void) { return mck_registerObjectMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static char* mck_anyCString(void) { return mck_registerCStringMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static SEL mck_anySelector(void) { return mck_registerSelectorMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static void* mck_anyPointer(void) { return mck_registerPointerMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static __autoreleasing id* mck_anyObjectPointer(void) { return (__autoreleasing id *)mck_registerPointerMatcher([[RGMockAnyArgumentMatcher alloc] init]); }

#ifndef MOCK_DISABLE_NICE_SYNTAX
static char anyInt(void) { return mck_anyInt(); }
static char anyBool(void) { return mck_anyBool(); }
static id anyObject(void) { return mck_anyObject(); }
static char* anyCString(void) { return mck_anyCString(); }
static SEL anySelector(void) { return mck_anySelector(); }
static void* anyPointer(void) { return mck_anyPointer(); }
static __autoreleasing id* anyObjectPointer(void) { return mck_anyObjectPointer(); }
#endif
