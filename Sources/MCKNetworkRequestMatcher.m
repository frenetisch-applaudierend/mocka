//
//  MCKNetworkRequestMatcher.m
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKNetworkRequestMatcher.h"


@implementation MCKNetworkRequestMatcher

#pragma mark - Initialization

+ (instancetype)matcherForURL:(NSURL *)url HTTPMethod:(NSString *)method {
    return [[self alloc] initWithURL:url HTTPMethod:method];
}

- (instancetype)initWithURL:(NSURL *)url HTTPMethod:(NSString *)method {
    if ((self = [super init])) {
        _URL = [url copy];
        _HTTPMethod = [method copy];
    }
    return self;
}


#pragma mark - Argument Matching

- (BOOL)matchesCandidate:(NSURLRequest *)candidate {
    return NO;
}

@end
