//
//  RGMockObject.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockRecorder.h"


@interface RGMockRecorder () {
@private
    NSMutableArray *_recordedInvocations;
}
@end


@implementation RGMockRecorder

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _recordedInvocations = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Invocation Recording

- (void)mock_recordInvocation:(NSInvocation *)invocation {
    [_recordedInvocations addObject:invocation];
}

- (NSArray *)mock_recordedInvocations {
    return [_recordedInvocations copy];
}

- (NSArray *)mock_recordedInvocationsMatchingInvocation:(NSInvocation *)invocation {
    return [_recordedInvocations filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(NSInvocation *candidate, NSDictionary *bindings) {
        return (invocation.selector == candidate.selector && invocation.target == candidate.target);
    }]];
}


#pragma mark - Handling Unknown Methods

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self mock_recordInvocation:invocation];
}

@end
