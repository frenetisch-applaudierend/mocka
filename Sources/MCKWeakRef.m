//
//  MCKWeakRef.m
//  mocka
//
//  Created by Markus Gasser on 11.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKWeakRef.h"


@implementation MCKWeakRef

+ (instancetype)weakRefForObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (instancetype)initWithObject:(id)object
{
    if ((self = [super init])) {
        _object = object;
    }
    return self;
}

@end
