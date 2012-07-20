//
//  RGMockTypeEncodings.h
//  rgmock
//
//  Created by Markus Gasser on 20.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


#import <Foundation/Foundation.h>


static const char* typeBySkippingTypeModifiers(const char *type) {
    while (type[0] == 'r' || type[0] == 'n' || type[0] == 'N' || type[0] == 'o' || type[0] == 'O' || type[0] == 'R' || type[0] == 'V') {
        type++;
    }
    return type;
}

static BOOL isPrimitiveType(const char *type) {
    type = typeBySkippingTypeModifiers(type);
    switch (type[0]) {
            // Primitive type encodings
        case 'c': case 'i': case 's': case 'l': case 'q':
        case 'C': case 'I': case 'S': case 'L': case 'Q':
        case 'f': case 'd':
        case 'B':
            return YES;
            
        default:
            return NO;
    }
}

static BOOL isObjectType(const char *type) {
    type = typeBySkippingTypeModifiers(type);
    return (type[0] == '@' || type[0] == '#');
}

static BOOL isSelectorOrCStringType(const char *type) {
    type = typeBySkippingTypeModifiers(type);
    return (type[0] == ':' || type[0] == '*'); // * never gets reported strangely, c strings are reported as : as well
}

static BOOL isVoidType(const char *type) {
    type = typeBySkippingTypeModifiers(type);
    return type[0] == 'v';
}
