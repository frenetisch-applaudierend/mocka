//
//  FakeFailureHandler.h
//  mocka
//
//  Created by Markus Gasser on 16.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKFailureHandler.h"


@interface FakeFailureHandler : NSObject <MCKFailureHandler>

@property (nonatomic, readonly) NSArray *capturedFailures;

@end


@interface CapturedFailure : NSObject

+ (instancetype)failureWithLocation:(MCKLocation *)location reason:(NSString *)reason;

@property (nonatomic, readonly) MCKLocation *location;
@property (nonatomic, readonly) NSString *reason;

@end
