//
//  MCKNetworkMock.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKNetworkMock.h"


@implementation MCKNetworkMock

+ (instancetype)sharedMock {
    return [[self alloc] init];
}

- (MCKNetworkMock*(^)(id))GET {
    return ^(id url) {
        return self;
    };
}

- (MCKNetworkMock*(^)(NSDictionary*))withHeaders {
    return ^(NSDictionary *headers) {
        return self;
    };
}

@end
