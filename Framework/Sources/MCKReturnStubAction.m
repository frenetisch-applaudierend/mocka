//
//  MCKReturnStubAction.m
//  mocka
//
//  Created by Markus Gasser on 16.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKReturnStubAction.h"
#import "MCKTypeEncodings.h"
#import <objc/runtime.h>


@implementation MCKReturnStubAction

#pragma mark - Initialization

+ (id)returnActionWithValue:(id)value {
    return [[self alloc] initWithValue:value];
}

- (id)initWithValue:(id)value {
    if ((self = [super init])) {
        _returnValue = value;
    }
    return self;
}


#pragma mark - Performing the Action

- (void)performWithInvocation:(NSInvocation *)invocation {
    #define HandlePrimitive(type, sel) { type value = [_returnValue sel]; [invocation setReturnValue:&value]; break; }
    char type = [MCKTypeEncodings typeBySkippingTypeModifiers:invocation.methodSignature.methodReturnType][0];
    switch (type) {
        // Handle primitive types
        case 'c': HandlePrimitive(char, charValue);
        case 's': HandlePrimitive(short, shortValue);
        case 'i': HandlePrimitive(int, intValue);
        case 'l': HandlePrimitive(long, longValue);
            
        case 'q': HandlePrimitive(long long, unsignedLongLongValue);
        case 'C': HandlePrimitive(unsigned char, unsignedCharValue);
        case 'S': HandlePrimitive(unsigned short, unsignedShortValue);
        case 'I': HandlePrimitive(unsigned int, unsignedIntValue);
        case 'L': HandlePrimitive(unsigned long, unsignedLongValue);
            
        case 'Q': HandlePrimitive(unsigned long long, unsignedLongLongValue);
        case 'f': HandlePrimitive(float, floatValue);
        case 'd': HandlePrimitive(double, doubleValue);
            
        // Handle object types
        case '@': { [invocation setReturnValue:&_returnValue]; break; }
        case '#': { [invocation setReturnValue:&_returnValue]; break; }
            
            // Handle struct types
        case '{': {
            void *structValue = malloc([invocation.methodSignature methodReturnLength]);
            [(NSValue *)_returnValue getValue:structValue];
            [invocation setReturnValue:structValue];
            free(structValue);
            break;
        }
            
            // Handle pointer types
        case '^': { void *value = [(NSValue *)_returnValue pointerValue]; [invocation setReturnValue:&value]; break; }
    }
}


#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p returnValue=%@>", [self class], self, _returnValue];
}

@end


id mck_createGenericValue(const char *typeString, ...) {
    va_list args;
    va_start(args, typeString);
    id returnValue = nil;
    char type = [MCKTypeEncodings typeBySkippingTypeModifiers:typeString][0];
    
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
