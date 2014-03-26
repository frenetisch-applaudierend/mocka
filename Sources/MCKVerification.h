//
//  MCKVerification.h
//  mocka
//
//  Created by Markus Gasser on 26.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MCKVerificationHandler;
@class MCKLocation;


@interface MCKVerification : NSObject

- (instancetype)initWithVerificationBlock:(void(^)(void))block
                      verificationHandler:(id<MCKVerificationHandler>)handler
                                  timeout:(NSTimeInterval)timeout
                                 location:(MCKLocation *)location;

@property (nonatomic, readonly) void(^verificationBlock)(void);
@property (nonatomic, readonly) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, readonly) NSTimeInterval timeout;
@property (nonatomic, readonly) MCKLocation *location;

@end
