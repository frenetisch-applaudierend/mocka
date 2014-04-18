//
//  FakeFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 16.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "FakeFailureHandler.h"

@implementation FakeFailureHandler {
    NSMutableArray *_capturedFailures;
}

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _capturedFailures = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Handling Failures

- (NSArray *)capturedFailures {
    return [_capturedFailures copy];
}

- (void)handleFailureAtLocation:(MCKLocation *)location withReason:(NSString *)reason {
    [_capturedFailures addObject:[CapturedFailure failureWithLocation:location reason:reason]];
}

@end


@implementation CapturedFailure

+ (instancetype)failureWithLocation:(MCKLocation *)location reason:(NSString *)reason {
    return [[self alloc] initWithLocation:location reason:reason];
}

- (instancetype)initWithLocation:(MCKLocation *)location reason:(NSString *)reason {
    if ((self = [super init])) {
        _location = [location copy];
        _reason = [reason copy];
    }
    return self;
}

@end
