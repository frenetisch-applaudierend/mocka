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

#define MCKRegisterMatcher(M, T) ((T)(*((T const *)_MCKRegisterMatcherWithType((M), (void *)(const T[]){0}, @encode(T)))))


#pragma mark - Find Registered Matchers




#pragma mark - Internal

extern void* _MCKRegisterMatcherWithType(id<MCKArgumentMatcher> matcher, void *holder, const char *type);
extern UInt8 _MCKMatcherIndexForPrimitiveArgument(const void *bytes);
