//
//  MCKValueSerialization.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Value Serialization

/**
 * Uses MCKSerializeValueFromBytesAndType() to serialize the passed value.
 */
#define MCKSerializeValue(V) MCKSerializeValueFromBytesAndType(((typeof(V)[]){ (V) }), @encode(typeof(V)))

/**
 * Serialize a given value to a NSValue or a subclass thereof.
 *
 * Scalars (int, etc) are serialized into NSNumber instances, all other values
 * are converted to NSValue instances, including objects.
 *
 * This means to compare objects you need to unpack the value first. Scalars can be
 * compared using -isEqual: and -compare:.
 */
extern NSValue* MCKSerializeValueFromBytesAndType(const void *bytes, const char *type);


#pragma mark - Value Deserialization

/**
 * Uses MCKDeserializeValueOfType() to deserialize the given NSValue then casts to the desired type.
 */
#define MCKDeserializeValue(S, T) (T)(*(const T *)MCKDeserializeValueOfType((S), &(T){ 0 }))

/**
 * Deserialize a NSValue instance.
 */
extern void* MCKDeserializeValueOfType(NSValue *serialized, void *valueRef);


@interface NSValue (MCKValueSerialization)

/**
 * Returns the receiver's value as a selector.
 *
 * @return The receiver's value as a selector. If the receiver was not created to hold a selector data item,
 *         the result is undefined.
 */
- (SEL)mck_selectorValue;

@end
