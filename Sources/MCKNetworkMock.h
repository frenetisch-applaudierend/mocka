//
//  MCKNetworkMock.h
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCKNetworkMock : NSObject

+ (instancetype)sharedMock;

@property (nonatomic, readonly) MCKNetworkMock*(^GET)(id url);
@property (nonatomic, readonly) MCKNetworkMock*(^withHeaders)(NSDictionary *headers);

@end


#define MCKNetwork [MCKNetworkMock sharedMock]
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define Network MCKNetwork
#endif
