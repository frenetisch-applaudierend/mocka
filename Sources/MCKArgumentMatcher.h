//
//  MCKArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKArgumentMatcher <NSObject>

- (BOOL)matchesCandidate:(NSValue *)serializedCandidate;

@end


@interface MCKArgumentMatcher : NSObject <MCKArgumentMatcher>

- (BOOL)matchesCandidate:(NSValue *)serializedCandidate;
- (BOOL)matchesObjectCandidate:(id)candidate;
- (BOOL)matchesNonObjectCandidate:(NSValue *)candidate;

@end


#pragma mark - Registering Matchers

#define MCKRegisterMatcher(M, T) (*((const T *)_MCKRegisterMatcherWithType((M), (T[]){0}, @encode(T))))


#pragma mark - Internal

extern void* _MCKRegisterMatcherWithType(id<MCKArgumentMatcher> matcher, void *holder, const char *type);

extern char* mck_registerCStringMatcher(id<MCKArgumentMatcher> matcher);
extern SEL mck_registerSelectorMatcher(id<MCKArgumentMatcher> matcher);
extern void* mck_registerPointerMatcher(id<MCKArgumentMatcher> matcher);

#define mck_registerStructMatcher(MATCHER, STRT_TYPE)\
    (*((STRT_TYPE *)_mck_registerStructMatcher((MATCHER), &(STRT_TYPE){}, sizeof(STRT_TYPE))))
extern const void* _mck_registerStructMatcher(id<MCKArgumentMatcher> matcher, void *inputStruct, size_t structSize);


#pragma mark - Find Registered Matchers

extern UInt8 MCKMatcherIndexForPrimitiveArgument(const void *bytes);
