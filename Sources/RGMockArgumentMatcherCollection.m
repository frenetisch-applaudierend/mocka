//
//  RGMockArgumentMatcherCollection.m
//  rgmock
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockArgumentMatcherCollection.h"

@implementation RGMockArgumentMatcherCollection

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _nonObjectArgumentMatchers = [NSMutableArray array];
    }
    return self;
}

@end
