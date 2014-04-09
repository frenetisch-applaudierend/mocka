//
//  MCKArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKArgumentMatcher.h"
#import "MCKArgumentMatcher+Subclasses.h"

#import "MCKMockingContext.h"
#import "MCKArgumentMatcherRecorder.h"


@implementation MCKArgumentMatcher

- (BOOL)matchesCandidate:(NSValue *)serializedCandidate
{
    if ([MCKTypeEncodings isObjectType:[serializedCandidate objCType]]) {
        return [self matchesObjectCandidate:[serializedCandidate nonretainedObjectValue]];
    }
    else {
        return [self matchesNonObjectCandidate:serializedCandidate];
    }
}

- (BOOL)matchesObjectCandidate:(id)candidate
{
    return NO;
}

- (BOOL)matchesNonObjectCandidate:(NSValue *)candidate
{
    return NO;
}

@end

id mck_registerObjectMatcher(id<MCKArgumentMatcher> matcher) {
    [[MCKMockingContext currentContext].argumentMatcherRecorder addObjectArgumentMatcher:matcher];
    return matcher; // object matchers are passed directly as argument
}

UInt8 mck_registerPrimitiveNumberMatcher(id<MCKArgumentMatcher> matcher) {
    return [[MCKMockingContext currentContext].argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
}

char* mck_registerCStringMatcher(id<MCKArgumentMatcher> matcher) {
    UInt8 index = [[MCKMockingContext currentContext].argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
    char *returnValue = NULL;
    return *((char **)memset(&returnValue, index, 1));
}

SEL mck_registerSelectorMatcher(id<MCKArgumentMatcher> matcher) {
    UInt8 index = [[MCKMockingContext currentContext].argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
    SEL returnValue = NULL;
    return *((SEL *)memset(&returnValue, index, 1));
}

void* mck_registerPointerMatcher(id<MCKArgumentMatcher> matcher) {
    UInt8 index = [[MCKMockingContext currentContext].argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
    void *returnValue = NULL;
    return *((void **)memset(&returnValue, index, 1));
}

const void* _mck_registerStructMatcher(id<MCKArgumentMatcher> matcher, void *inputStruct, size_t structSize) {
    NSCParameterAssert(inputStruct != NULL);
    NSCParameterAssert(structSize >= sizeof(UInt8));
    
    UInt8 index = [[MCKMockingContext currentContext].argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
    return memset(inputStruct, index, 1);
}


#pragma mark - Find Registered Matchers

UInt8 mck_matcherIndexForArgumentBytes(const void *bytes) {
    return ((UInt8 *)bytes)[0];
}
