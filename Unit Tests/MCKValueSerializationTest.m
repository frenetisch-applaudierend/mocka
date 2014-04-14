//
//  MCKValueSerializationTest.m
//  mocka
//
//  Created by Markus Gasser on 09.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKValueSerialization.h"


@interface MCKValueSerializationTest : XCTestCase @end
@implementation MCKValueSerializationTest

#pragma mark - Test Object Serializing and Deserializing

- (void)testThatObjectIsSerializedAsNSValue
{
    NSValue *serialized = MCKSerializeValue(@"Hello");
    
    expect(serialized).to.beKindOf([NSValue class]);
    expect(strcmp([serialized objCType], @encode(id))).to.equal(0);
}

- (void)testThatObjectIsDeserialized
{
    id value = @"Hello";
    NSValue *serialized = [NSValue valueWithBytes:&value objCType:@encode(id)];
    
    id deserialized = MCKDeserializeValue(serialized, id);
    
    expect(deserialized).to.equal(value);
}

- (void)testThatClassIsSerializedAsNSValue
{
    NSValue *serialized = MCKSerializeValue([NSObject class]);
    
    expect(serialized).to.beKindOf([NSValue class]);
    expect(strcmp([serialized objCType], @encode(Class))).to.equal(0);
}

- (void)testThatClassIsDeserialized
{
    Class value = [NSObject class];
    NSValue *serialized = [NSValue valueWithBytes:&value objCType:@encode(Class)];
    
    Class deserialized = MCKDeserializeValue(serialized, Class);
    
    expect(deserialized).to.equal(value);
}


#pragma mark - Test Scalar Serializing and Deserializing

- (void)testThatCharIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((char)-10);
    
    expect(serialized).to.equal(@-10);
}

- (void)testThatCharIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(char){ -10 } objCType:@encode(char)];
    
    char deserialized = MCKDeserializeValue(serialized, char);
    
    expect(deserialized).to.equal(-10);
}

- (void)testThatUnsignedCharIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((unsigned char)10);
    
    expect(serialized).to.equal(@10);
}

- (void)testThatUnsignedCharIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(char){ 10 } objCType:@encode(unsigned char)];
    
    unsigned char deserialized = MCKDeserializeValue(serialized, unsigned char);
    
    expect(deserialized).to.equal(10);
}

- (void)testThatShortIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((short)-10);
    
    expect(serialized).to.equal(@-10);
}

- (void)testThatShortIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(short){ -10 } objCType:@encode(short)];
    
    short deserialized = MCKDeserializeValue(serialized, short);
    
    expect(deserialized).to.equal(-10);
}

- (void)testThatUnsignedShortIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((unsigned short)10);
    
    expect(serialized).to.equal(@10);
}

- (void)testThatUnsignedShortIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(short){ 10 } objCType:@encode(unsigned short)];
    
    unsigned short deserialized = MCKDeserializeValue(serialized, unsigned short);
    
    expect(deserialized).to.equal(10);
}

- (void)testThatIntIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((int)-10);
    
    expect(serialized).to.equal(@-10);
}

- (void)testThatIntIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(int){ -10 } objCType:@encode(int)];
    
    int deserialized = MCKDeserializeValue(serialized, int);
    
    expect(deserialized).to.equal(-10);
}

- (void)testThatUnsignedIntIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((unsigned int)10);
    
    expect(serialized).to.equal(@10);
}

- (void)testThatUnsignedIntIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(int){ 10 } objCType:@encode(unsigned int)];
    
    unsigned int deserialized = MCKDeserializeValue(serialized, unsigned int);
    
    expect(deserialized).to.equal(10);
}

- (void)testThatLongIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((long)-10);
    
    expect(serialized).to.equal(@-10);
}

- (void)testThatLongIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(long){ -10 } objCType:@encode(long)];
    
    long deserialized = MCKDeserializeValue(serialized, long);
    
    expect(deserialized).to.equal(-10);
}

- (void)testThatUnsignedLongIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((unsigned long)10);
    
    expect(serialized).to.equal(@10);
}

- (void)testThatUnsignedLongIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(long){ 10 } objCType:@encode(unsigned long)];
    
    unsigned long deserialized = MCKDeserializeValue(serialized, unsigned long);
    
    expect(deserialized).to.equal(10);
}

- (void)testThatLongLongIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((long long)-10);
    
    expect(serialized).to.equal(@-10);
}

- (void)testThatLongLongIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(long long){ -10 } objCType:@encode(long long)];
    
    long long deserialized = MCKDeserializeValue(serialized, long long);
    
    expect(deserialized).to.equal(-10);
}

- (void)testThatUnsignedLongLongIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue((unsigned long long)10);
    
    expect(serialized).to.equal(@10);
}

- (void)testThatUnsignedLongLongIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(long long){ 10 } objCType:@encode(unsigned long long)];
    
    unsigned long long deserialized = MCKDeserializeValue(serialized, unsigned long long);
    
    expect(deserialized).to.equal(10);
}

- (void)testThatFloatIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue(10.0f);
    
    expect(serialized).to.equal(@10.0f);
}

- (void)testThatFloatIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(float){ 10.0f } objCType:@encode(float)];
    
    float deserialized = MCKDeserializeValue(serialized, float);
    
    expect(deserialized).to.equal(10.0f);
}

- (void)testThatDoubleIsSerializedAsNSNumber
{
    NSValue *serialized = MCKSerializeValue(10.0);
    
    expect(serialized).to.equal(@10.0);
}

- (void)testThatDoubleIsDeserialized
{
    NSValue *serialized = [NSValue valueWithBytes:&(double){ 10.0 } objCType:@encode(double)];
    
    double deserialized = MCKDeserializeValue(serialized, double);
    
    expect(deserialized).to.equal(10.0);
}

@end
