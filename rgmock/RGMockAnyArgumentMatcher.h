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
static char mock_anyInt(void) { return mock_registerPrimitiveMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static char mock_anyBool(void) { return mock_anyInt(); }
static id mock_anyObject(void) { return mock_registerObjectMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static char* mock_anyCString(void) { return mock_registerCStringMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static SEL mock_anySelector(void) { return mock_registerSelectorMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static void* mock_anyPointer(void) { return mock_registerPointerMatcher([[RGMockAnyArgumentMatcher alloc] init]); }
static __autoreleasing id* mock_anyObjectPointer(void) { return (__autoreleasing id *)mock_registerPointerMatcher([[RGMockAnyArgumentMatcher alloc] init]); }

#ifndef MOCK_DISABLE_NICE_SYNTAX
static char anyInt(void) { return mock_anyInt(); }
static char anyBool(void) { return mock_anyBool(); }
static id anyObject(void) { return mock_anyObject(); }
static char* anyCString(void) { return mock_anyCString(); }
static SEL anySelector(void) { return mock_anySelector(); }
static void* anyPointer(void) { return mock_anyPointer(); }
static __autoreleasing id* anyObjectPointer(void) { return mock_anyObjectPointer(); }
#endif
