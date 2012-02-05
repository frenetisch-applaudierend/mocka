//
//  RGMockObject.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockRecorder.h"
#import "RGMockInvocationMatcher.h"


@interface RGMockRecorder () {
@private
    RGMockInvocationMatcher *_invocationMatcher;
    NSMutableArray          *_recordedInvocations;
}
@end


@implementation RGMockRecorder

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _invocationMatcher = [[RGMockInvocationMatcher alloc] init];
        _recordedInvocations = [NSMutableArray array];
    }
    return self;
}

- (id)initWithInvocationMatcher:(RGMockInvocationMatcher *)matcher {
    if ((self = [self init])) {
        _invocationMatcher = matcher;
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


#pragma mark - Invocation Matching

- (NSArray *)mock_recordedInvocationsMatchingInvocation:(NSInvocation *)invocation {
    return [_recordedInvocations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id recorded, NSDictionary *bindings) {
        return [_invocationMatcher invocation:invocation matchesInvocation:recorded];
    }]];
}


#pragma mark - Handling Unknown Methods

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self mock_recordInvocation:invocation];
}

@end
