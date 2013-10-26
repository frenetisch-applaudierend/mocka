//
//  MCKNetworkRequestMatcher.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKNetworkRequestMatcher.h"


@implementation MCKNetworkRequestMatcher

- (MCKNetworkRequestMatcher*(^)(NSDictionary*))withHeaders {
    return ^(NSDictionary *headers) {
        return self;
    };
}

@end
