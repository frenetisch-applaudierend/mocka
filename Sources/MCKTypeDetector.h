//
//  MCKTypeDetector.h
//  mocka
//
//  Created by Markus Gasser on 22.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCKTypeDetector : NSObject

+ (BOOL)isClass:(id)object;
+ (BOOL)isProtocol:(id)object;
+ (BOOL)isObject:(id)object;

@end
