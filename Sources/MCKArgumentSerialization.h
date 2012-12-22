//
//  MCKArgumentSerialization.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKTypeEncodings.h"


#pragma mark - Object Arguments

static inline id mck_encodeObjectArgument(id arg) {
    return arg;
}

static inline id mck_decodeObjectArgument(id serialized) {
    return serialized;
}


#pragma mark - Primitive Arguments

static inline id mck_encodeSignedIntegerArgument(SInt64 arg) {
    return @(arg);
}

static inline SInt64 mck_decodeSignedIntegerArgument(id serialized) {
    return [serialized longLongValue];
}

static inline id mck_encodeUnsignedIntegerArgument(UInt64 arg) {
    return @(arg);
}

static inline SInt64 mck_decodeUnsignedIntegerArgument(id serialized) {
    return [serialized unsignedLongLongValue];
}

static inline id mck_encodeFloatingPointArgument(double arg) {
    return @(arg);
}

static inline double mck_decodeFloatingPointArgument(id serialized) {
    return [serialized doubleValue];
}


#pragma mark - Non-Object Pointer Types

static inline id mck_encodePointerArgument(const void *arg) {
    return [NSValue valueWithPointer:arg];
}

static inline void* mck_decodePointerArgument(id serialized) {
    return [serialized pointerValue];
}

static inline id mck_encodeCStringArgument(const char *arg) {
    return [NSString stringWithUTF8String:arg];
}

static inline const char* mck_decodeCStringArgument(id serialized) {
    return [serialized UTF8String];
}

static inline id mck_encodeStructBytes(const void *arg, const char *type) {
    return [NSValue valueWithBytes:arg objCType:type];
}

static inline void* mck_decodeStructBytes(id serialized, void *arg) {
    [serialized getValue:arg];
    return arg;
}

#define mck_encodeStructArgument(arg) mck_encodeStructBytes((typeof(arg)[]){ (arg) }, @encode(typeof(arg)))

#define mck_decodeStructArgument(serialized, structType) *((structType *)mck_decodeStructBytes(serialized, &(structType){}))


#pragma mark - Generic Encoding

static id mck_encodeValueFromBytesAndType(const void *bytes, size_t size, const char *type) {
    type = [MCKTypeEncodings typeBySkippingTypeModifiers:type];
    
    switch (type[0]) {
        case '@': return mck_encodeObjectArgument(*(__unsafe_unretained id *)bytes);
        case '#': return mck_encodeObjectArgument(*((Class *)bytes));
        
        case 'c': return mck_encodeSignedIntegerArgument(*(char *)bytes);
        case 'i': return mck_encodeSignedIntegerArgument(*(int *)bytes);
        case 's': return mck_encodeSignedIntegerArgument(*(short *)bytes);
        case 'l': return mck_encodeSignedIntegerArgument(*(long *)bytes);
        case 'q': return mck_encodeSignedIntegerArgument(*(long long *)bytes);
            
        case 'C': return mck_encodeUnsignedIntegerArgument(*(unsigned char *)bytes);
        case 'I': return mck_encodeUnsignedIntegerArgument(*(unsigned int *)bytes);
        case 'S': return mck_encodeUnsignedIntegerArgument(*(unsigned short *)bytes);
        case 'L': return mck_encodeUnsignedIntegerArgument(*(unsigned long *)bytes);
        case 'Q': return mck_encodeUnsignedIntegerArgument(*(unsigned long long *)bytes);
            
        case 'f': return mck_encodeFloatingPointArgument(*(float *)bytes);
        case 'd': return mck_encodeFloatingPointArgument(*(double *)bytes);
            
        case 'B': return mck_encodeUnsignedIntegerArgument(*(_Bool *)bytes);
            
        case '*': return mck_encodeCStringArgument(*(void **)bytes);
        
        case ':':
        case '^':
        case '[': return mck_encodePointerArgument(*(void **)bytes);
        
        case '{': return mck_encodeStructBytes(bytes, type);
            
        default: {
            NSString *reason = [NSString stringWithFormat:@"Unknown type encoding: %s", type];
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        }
    }
}
