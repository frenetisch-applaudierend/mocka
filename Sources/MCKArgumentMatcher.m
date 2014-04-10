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


#pragma mark - Registering and Finding Matchers

void* _MCKRegisterMatcherWithType(id<MCKArgumentMatcher> matcher, void *holder, const char *type)
{
    if ([MCKTypeEncodings isObjectType:type]) {
        [[MCKMockingContext currentContext].argumentMatcherRecorder addObjectArgumentMatcher:matcher];
        *(__unsafe_unretained id *)holder = matcher;
    }
    else {
        UInt8 idx = [[MCKMockingContext currentContext].argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
        ((UInt8 *)holder)[0] = idx;
    }
    return holder;
}

UInt8 _MCKMatcherIndexForPrimitiveArgument(const void *bytes) {
    return ((const UInt8 *)bytes)[0];
}
