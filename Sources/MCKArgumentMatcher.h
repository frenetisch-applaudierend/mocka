//
//  MCKArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKMockingContext.h"


@protocol MCKArgumentMatcher <NSObject>

- (BOOL)matchesCandidate:(id)candidate;

@end


// Registering Matchers

static inline id mck_registerObjectMatcher(id<MCKArgumentMatcher> matcher) {
    // no need to push the matcher to the context, since it can be passed directly via argument
    return matcher;
}

static inline char mck_registerPrimitiveNumberMatcher(id<MCKArgumentMatcher> matcher) {
    return [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
}

static inline char* mck_registerCStringMatcher(id<MCKArgumentMatcher> matcher) {
    return (char[]) { [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher], '\0' };
}

static inline SEL mck_registerSelectorMatcher(id<MCKArgumentMatcher> matcher) {
    return (SEL)((char[]) { [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher], '\0' });
}

static inline void* mck_registerPointerMatcher(id<MCKArgumentMatcher> matcher) {
    return (void *)[[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
}

static inline const void* mck_createStructForMatcher(id<MCKArgumentMatcher> matcher, size_t structSize) {
    if (structSize < sizeof(UInt8)) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Struct must have at least one member" userInfo:nil];
    }
    
    NSMutableData *structData = [[NSMutableData alloc] initWithLength:structSize];
    ((UInt8 *)structData.bytes)[0] = [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
    return structData.bytes;
}

#define mck_registerStructMatcher(matcher, structType) ((structType)mck_createStructForMatcher((matcher), (sizeof(structType))))
