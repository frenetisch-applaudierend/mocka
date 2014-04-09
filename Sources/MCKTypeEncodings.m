//
//  MCKTypeEncodings.m
//  mocka
//
//  Created by Markus Gasser on 21.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKTypeEncodings.h"


#define MCKEqualTypes(T1, T2) (strcmp(T1, T2) == 0)

@implementation MCKTypeEncodings

#pragma mark - Get Information about @encode() types

+ (BOOL)isObjectType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    return ((type[0] == @encode(id)[0]) || (type[0] == @encode(Class)[0]));
}

+ (BOOL)isSelectorType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    return MCKEqualTypes(type, @encode(SEL));
}

+ (BOOL)isCStringType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    return MCKEqualTypes(type, @encode(const char*));
}

+ (BOOL)isPointerType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    return (type[0] == @encode(void*)[0]);
}

+ (BOOL)isScalarType:(const char *)type {
    type = [self typeBySkippingTypeModifiers:type];
    
    return (   MCKEqualTypes(type, @encode(int8_t))  || MCKEqualTypes(type, @encode(uint8_t))
            || MCKEqualTypes(type, @encode(int16_t)) || MCKEqualTypes(type, @encode(uint16_t))
            || MCKEqualTypes(type, @encode(int32_t)) || MCKEqualTypes(type, @encode(uint32_t))
            || MCKEqualTypes(type, @encode(int64_t)) || MCKEqualTypes(type, @encode(uint64_t))
            || MCKEqualTypes(type, @encode(float))   || MCKEqualTypes(type, @encode(double)));
}


#pragma mark - Testing for Equality

+ (BOOL)isType:(const char *)type equalToType:(const char *)other {
    type = [self typeBySkippingTypeModifiers:type];
    other = [self typeBySkippingTypeModifiers:other];
    if ([self isObjectType:type]) {
        return type[0] == other[0];
    } else {
        return (strcmp(type, other) == 0);
    }
}


#pragma mark - Prepare @encode() types

+ (const char *)typeBySkippingTypeModifiers:(const char *)type {
    while (type[0] == 'r' || type[0] == 'n' || type[0] == 'N' || type[0] == 'o' || type[0] == 'O' || type[0] == 'R' || type[0] == 'V') { type++; }
    return type;
}

@end
