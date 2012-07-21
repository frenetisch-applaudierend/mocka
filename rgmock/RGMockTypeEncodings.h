//
//  RGMockTypeEncodings.h
//  rgmock
//
//  Created by Markus Gasser on 20.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


#import <Foundation/Foundation.h>


#pragma mark - Get Information about @encode() types

BOOL isPrimitiveType(const char *type);
BOOL isObjectType(const char *type);
BOOL isSelectorOrCStringType(const char *type);
BOOL isStructType(const char *type);
BOOL isVoidType(const char *type);


#pragma mark - Prepare @encode() types

const char* typeBySkippingTypeModifiers(const char *type);