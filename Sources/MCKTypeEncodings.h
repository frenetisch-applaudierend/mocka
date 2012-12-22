//
//  MCKTypeEncodings.h
//  mocka
//
//  Created by Markus Gasser on 20.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface MCKTypeEncodings : NSObject

#pragma mark - Get Information about @encode() types

//+ (BOOL)isPrimitiveType:(const char *)type;
+ (BOOL)isSignedIntegerType:(const char *)type;
+ (BOOL)isUnsignedIntegerType:(const char *)type;
+ (BOOL)isFloatingPointType:(const char *)type;
+ (BOOL)isBuiltinBoolType:(const char *)type;
+ (BOOL)isObjectType:(const char *)type;
+ (BOOL)isSelectorType:(const char *)type;
+ (BOOL)isCStringType:(const char *)type;
+ (BOOL)isPointerType:(const char *)type;
+ (BOOL)isStructType:(const char *)type;
+ (BOOL)isVoidType:(const char *)type;
+ (BOOL)isSelectorOrCStringType:(const char *)type;

+ (BOOL)isType:(const char *)type equalToType:(const char *)other;

#pragma mark - Prepare @encode() types

+ (const char *)typeBySkippingTypeModifiers:(const char *)type;

@end