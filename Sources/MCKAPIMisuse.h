//
//  MCKAPIMisuse.h
//  mocka
//
//  Created by Markus Gasser on 23.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const MCKAPIMisuseException;

extern void MCKAPIMisuse(NSString *reason, ...) NS_FORMAT_FUNCTION(1,2) __attribute__((noreturn));
