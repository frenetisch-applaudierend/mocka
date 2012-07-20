//
//  RGMockReturnStubAction.m
//  rgmock
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockReturnStubAction.h"
#import <objc/runtime.h>


static const NSUInteger MemoryBlockKey;
@interface RGMockMemoryBlock : NSObject
+ (id)memoryBlockOfSize:(size_t)size attachToObject:(id)object;
- (void *)pointerValue;
@end


@implementation RGMockReturnStubAction {
    id _value;
}

#pragma mark - Initialization

+ (id)returnActionWithValue:(id)value {
    return [[self alloc] initWithValue:value];
}

- (id)initWithValue:(id)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}


#pragma mark - Performing the Action

- (void)performWithInvocation:(NSInvocation *)invocation {
    #define HandlePrimitive(code, type, sel) case code: { type value = [_value sel]; [invocation setReturnValue:&value]; break; }
    char type = typeBySkippingTypeModifiers(invocation.methodSignature.methodReturnType)[0];
    switch (type) {
            // Handle primitive types
            HandlePrimitive('c', char, charValue)
            HandlePrimitive('s', short, shortValue)
            HandlePrimitive('i', int, intValue)
            HandlePrimitive('l', long, longValue)
            HandlePrimitive('q', long long, unsignedLongLongValue)
            HandlePrimitive('C', unsigned char, unsignedCharValue)
            HandlePrimitive('S', unsigned short, unsignedShortValue)
            HandlePrimitive('I', unsigned int, unsignedIntValue)
            HandlePrimitive('L', unsigned long, unsignedLongValue)
            HandlePrimitive('Q', unsigned long long, unsignedLongLongValue)
            HandlePrimitive('f', float, floatValue)
            HandlePrimitive('d', double, doubleValue)
            
            // Handle object types
        case '@': { [invocation setReturnValue:&_value]; break; }
        case '#': { [invocation setReturnValue:&_value]; break; }
            
            // Handle struct types
        case '{': {
            RGMockMemoryBlock *memoryBlock = [RGMockMemoryBlock memoryBlockOfSize:[invocation.methodSignature methodReturnLength]
                                                                   attachToObject:invocation];
            [(NSValue *)_value getValue:[memoryBlock pointerValue]];
            [invocation setReturnValue:[memoryBlock pointerValue]];
            break;
        }
            
            // Handle pointer types
        case '^': { void *value = [(NSValue *)_value pointerValue]; [invocation setReturnValue:&value]; break; }
    }
}

@end


@implementation RGMockMemoryBlock {
    void *_memoryBlock;
}

+ (id)memoryBlockOfSize:(size_t)size attachToObject:(id)object {
    id memoryBlock = [[self alloc] initWithSize:size];
    objc_setAssociatedObject(object, &MemoryBlockKey, memoryBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return memoryBlock;
}

- (id)initWithSize:(size_t)size {
    if ((self = [super init])) {
        _memoryBlock = malloc(size);
    }
    return self;
}

- (void)dealloc {
    free(_memoryBlock);
}

- (void *)pointerValue {
    return _memoryBlock;
}

@end


id mock_createGenericValue(const char *typeString, ...) {
    va_list args;
    va_start(args, typeString);
    id returnValue = nil;
    char type = typeBySkippingTypeModifiers(typeString)[0];
    
    switch (type) {
        // Primitive types
        case 'c': { int value = va_arg(args, int); returnValue = [NSNumber numberWithChar:(char)value]; break; }
        case 'i': { int value = va_arg(args, int); returnValue = [NSNumber numberWithInt:value]; break; }
        case 's': { int value = va_arg(args, int); returnValue = [NSNumber numberWithShort:(short)value]; break; }
        case 'l': { long value = va_arg(args, long); returnValue = [NSNumber numberWithLong:value]; break; }
        case 'q': { long long value = va_arg(args, long long); returnValue = [NSNumber numberWithLongLong:value]; break; }
        case 'C': { unsigned int value = va_arg(args, unsigned int); returnValue = [NSNumber numberWithUnsignedChar:(unsigned char)value]; break; }
        case 'I': { unsigned int value = va_arg(args, unsigned int); returnValue = [NSNumber numberWithUnsignedInt:value]; break; }
        case 'S': { unsigned int value = va_arg(args, unsigned int); returnValue = [NSNumber numberWithUnsignedShort:(unsigned short)value]; break; }
        case 'L': { unsigned long value = va_arg(args, unsigned long); returnValue = [NSNumber numberWithUnsignedLong:value]; break; }
        case 'Q': { unsigned long long value = va_arg(args, unsigned long long); returnValue = [NSNumber numberWithUnsignedLongLong:value]; break; }
        case 'f': { double value = va_arg(args, double); returnValue = [NSNumber numberWithFloat:(float)value]; break; }
        case 'd': { double value = va_arg(args, double); returnValue = [NSNumber numberWithDouble:value]; break; }
        
        // Object types
        case '@': { id value = va_arg(args, id); returnValue = value; break; }
        case '#': { Class value = va_arg(args, Class); returnValue = value; break; }
        
        // Pointer types
        case '^': { void *value = va_arg(args, void*); returnValue = (value != NULL ? [NSValue valueWithPointer:value] : nil); break; }
    }
    
    va_end(args);
    return returnValue;
}

