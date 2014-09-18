//
//  MCKValueSerialization.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKValueSerialization.h"

#import "MCKTypeEncodings.h"


#pragma mark - Value Serialization

NSValue* MCKSerializeValueFromBytesAndType(const void *bytes, const char *type)
{
    if ([MCKTypeEncodings isType:type equalToType:@encode(char)]) {
        return [NSNumber numberWithChar:(*(char *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(unsigned char)]) {
        return [NSNumber numberWithUnsignedChar:(*(unsigned char *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(short)]) {
        return [NSNumber numberWithShort:(*(short *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(unsigned short)]) {
        return [NSNumber numberWithUnsignedShort:(*(unsigned short *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(int)]) {
        return [NSNumber numberWithInt:(*(int *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(unsigned int)]) {
        return [NSNumber numberWithUnsignedInt:(*(unsigned int *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(long)]) {
        return [NSNumber numberWithLong:(*(long *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(unsigned long)]) {
        return [NSNumber numberWithUnsignedLong:(*(unsigned long *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(long long)]) {
        return [NSNumber numberWithLongLong:(*(long long *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(unsigned long long)]) {
        return [NSNumber numberWithUnsignedLongLong:(*(unsigned long long *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(float)]) {
        return [NSNumber numberWithFloat:(*(float *)bytes)];
    }
    else if ([MCKTypeEncodings isType:type equalToType:@encode(double)]) {
        return [NSNumber numberWithDouble:(*(double *)bytes)];
    }
    else {
        return [NSValue valueWithBytes:bytes objCType:type];
    }
}


#pragma mark - Value Deserialization

void* MCKDeserializeValueOfType(NSValue *serialized, void *valueRef)
{
    [serialized getValue:valueRef];
    return valueRef;
}


#pragma mark - NSValue Extension

@implementation NSValue (MCKValueSerialization)

- (SEL)mck_selectorValue
{
    SEL selector;
    [self getValue:&selector];
    return selector;
}

@end

