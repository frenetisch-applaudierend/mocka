//
//  RGMockExactlyVerificationHandler.m
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockExactlyVerificationHandler.h"
#import "RGMockInvocationMatcher.h"


@implementation RGMockExactlyVerificationHandler {
    NSUInteger _count;
}

#pragma mark - Initialization

+ (id)exactlyHandlerWithCount:(NSUInteger)count {
    return [[self alloc] initWithCount:count];
}

- (id)initWithCount:(NSUInteger)count {
    if ((self = [super init])) {
        _count = count;
    }
    return self;
}


#pragma mark - Matching Invocations

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
            withNonObjectArgumentMatchers:(NSArray *)argumentMatchers
                    inRecordedInvocations:(NSArray *)recordedInvocations
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    NSIndexSet *indexes = [recordedInvocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
        return [[RGMockInvocationMatcher defaultMatcher] invocation:candidate matchesPrototype:prototype withNonObjectArgumentMatchers:argumentMatchers];
    }];
    if (satisified != NULL) {
        *satisified = ([indexes count] == _count);
    }
    return (([indexes count] == _count) ? indexes : [NSIndexSet indexSet]);
}

@end