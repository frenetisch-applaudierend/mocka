//
//  AsyncService.h
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AsyncService : NSObject

+ (id)sharedService;

- (void)callBlockDelayed:(void(^)(void))block;
- (void)waitForTimeInterval:(NSTimeInterval)timeout thenCallBlock:(void(^)(void))block;

@end
