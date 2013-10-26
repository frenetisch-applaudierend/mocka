//
//  MCKNetworkMock.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKNetworkMock.h"
#import "MCKNetworkRequestMatcher.h"


@implementation MCKNetworkMock

#pragma mark - Initialization

+ (instancetype)sharedMock {
    static dispatch_once_t onceToken;
    static MCKNetworkMock *sharedMock = nil;
    dispatch_once(&onceToken, ^{
        sharedMock = [[self alloc] init];
    });
    return sharedMock;
}


#pragma mark - Request Configuration

- (MCKNetworkActivity)GET {
    return ^(id url) {
        return [MCKNetworkRequestMatcher matcherForURL:url HTTPMethod:@"GET"];
    };
}

@end
