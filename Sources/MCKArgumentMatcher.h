//
//  MCKArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKMockingContext.h"
#import "MCKTypeEncodings.h"


@protocol MCKArgumentMatcher <NSObject>

- (BOOL)matchesCandidate:(id)candidate;

@end


#pragma mark - Registering Matchers

static inline id mck_registerObjectMatcher(id<MCKArgumentMatcher> matcher) {
    // no need to push the matcher to the context, since it can be passed directly via argument
    return matcher;
}

static inline UInt8 mck_registerPrimitiveNumberMatcher(id<MCKArgumentMatcher> matcher) {
    return [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
}

#define MCKDefaultCStringBuffer (char[2]){ 0, 0 }
static inline char* mck_registerCStringMatcher(id<MCKArgumentMatcher> matcher, char buffer[2]) {
    buffer[0] = [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
    buffer[1] = '\0';
    return buffer;
}

static inline SEL mck_registerSelectorMatcher(id<MCKArgumentMatcher> matcher) {
    SEL returnValue = NULL;
    ((UInt8 *)&returnValue)[0] = [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
    return returnValue;
}

static inline void* mck_registerPointerMatcher(id<MCKArgumentMatcher> matcher) {
    void *returnValue = NULL;
    ((UInt8 *)&returnValue)[0] = [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
    return returnValue;
}

#define mck_registerStructMatcher(matcher, structType) (*((structType *)mck_createStructForMatcher((matcher), &(structType){}, sizeof(structType))))

static inline const void* mck_createStructForMatcher(id<MCKArgumentMatcher> matcher, void *inputStruct, size_t structSize) {
    NSCParameterAssert(inputStruct != NULL);
    NSCParameterAssert(structSize >= sizeof(UInt8));
    
    ((UInt8 *)inputStruct)[0] = [[MCKMockingContext currentContext] pushPrimitiveArgumentMatcher:matcher];
    return inputStruct;
}


#pragma mark - Find Registered Matchers

static inline UInt8 mck_matcherIndexForArgumentBytes(const void *bytes, const char *type) {
    type = [MCKTypeEncodings typeBySkippingTypeModifiers:type];
    return (type[0] == '*' ? (*((char **)bytes))[0] : ((UInt8 *)bytes)[0]);
}
