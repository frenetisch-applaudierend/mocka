//
//  KNMNilValue.h
//  KNMParametrizedTests
//
//  Created by Markus Gasser on 24.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Nil Value Support

/**
 * Use NIL (or knm_NIL) to represent a nil value as a parameter.
 */
#define knm_NIL _knm_nilValue()
#ifndef KNM_PARAM_NO_SHORTHAND
    #define NIL knm_NIL
#endif


#pragma mark - Struct and Scalar Support

/**
 * Use VALUE(...) to wrap a scalar or struct value as parameter.
 */
#define knm_VALUE(V) ({ typeof(V) _knm_val = (V); [NSValue valueWithBytes:&_knm_val objCType:@encode(typeof(V))]; })
#ifndef KNM_PARAM_NO_SHORTHAND
    #define VALUE(V) knm_VALUE(V)
#endif


#pragma mark - Internal

extern id _knm_nilValue(void);
