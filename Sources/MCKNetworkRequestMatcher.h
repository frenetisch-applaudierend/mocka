//
//  MCKNetworkRequestMatcher.h
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCKNetworkRequestMatcher : NSObject

@property (nonatomic, readonly) MCKNetworkRequestMatcher*(^withHeaders)(NSDictionary *headers);

@end
