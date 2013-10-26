//
//  MCKNetworkMock.h
//  mocka
//
//  Created by Markus Gasser on 26.10.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCKNetworkMock;
@class MCKNetworkRequestMatcher;
@class MCKMockingContext;

typedef MCKNetworkRequestMatcher*(^MCKNetworkActivity)(id url);


@interface MCKNetworkMock : NSObject

- (instancetype)initWithMockingContext:(MCKMockingContext *)context;

- (void)startObservingNetworkCalls;

@property (nonatomic, readonly) MCKNetworkActivity GET;
@property (nonatomic, readonly) MCKNetworkActivity PUT;
@property (nonatomic, readonly) MCKNetworkActivity POST;
@property (nonatomic, readonly) MCKNetworkActivity DELETE;

@end


#define MCKNetwork _mck_getNetworkMock(self, __FILE__, __LINE__)
#ifndef MCK_DISABLE_NICE_SYNTAX
    #define Network MCKNetwork
#endif
extern MCKNetworkMock* _mck_getNetworkMock(id testCase, const char *fileName, NSUInteger lineNumber);
