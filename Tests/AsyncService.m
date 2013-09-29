//
//  AsyncService.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "AsyncService.h"


@implementation AsyncService

+ (id)sharedService {
    static id sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    return sharedService;
}

- (void)waitForTimeInterval:(NSTimeInterval)timeout thenCallBlock:(void(^)())block {
    NSParameterAssert(block != nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

@end
