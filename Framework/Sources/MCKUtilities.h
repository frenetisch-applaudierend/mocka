//
//  MCKUtilities.h
//  mocka
//
//  Created by Markus Gasser on 07.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSInvocation+MCKArgumentHandling.h"

#define MCKSuppressRetainCylceWarning(code, ...) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-retain-cycles\"") \
        code, ##__VA_ARGS__; \
        _Pragma("clang diagnostic pop") \
    } while (0)
