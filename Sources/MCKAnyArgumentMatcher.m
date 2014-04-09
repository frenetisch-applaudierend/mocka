//
//  MCKAnyArgumentMatcher.m
//  mocka
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKAnyArgumentMatcher.h"


@implementation MCKAnyArgumentMatcher

- (BOOL)matchesCandidate:(id)candidate {
    return YES;
}

@end


#pragma mark - Mocking Syntax

id mck_anyObject(void) {
    return MCKRegisterMatcher([[MCKAnyArgumentMatcher alloc] init], id);
}

UInt8 mck_anyInt(void) {
    return MCKRegisterMatcher([[MCKAnyArgumentMatcher alloc] init], UInt8);
}

float mck_anyFloat(void) {
    return MCKRegisterMatcher([[MCKAnyArgumentMatcher alloc] init], float);
}

BOOL mck_anyBool(void) {
    return mck_anyInt();
}

char* mck_anyCString(void) {
    return mck_registerCStringMatcher([[MCKAnyArgumentMatcher alloc] init]);
}

SEL mck_anySelector(void) {
    return mck_registerSelectorMatcher([[MCKAnyArgumentMatcher alloc] init]);
}

void* mck_anyPointer(void) {
    return mck_registerPointerMatcher([[MCKAnyArgumentMatcher alloc] init]);
}
