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

- (BOOL)mock_invocation:(NSInvocation *)invocation1 matchesInvocation:(NSInvocation *)invocation2;
- (BOOL)mock_argumentAtIndex:(NSUInteger)index withType:(const char *)argType
         isEqualInInvocation:(NSInvocation *)invocation1 andInvocation:(NSInvocation *)invocation2;

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


#pragma mark - Invocation Matching

- (NSArray *)mock_recordedInvocationsMatchingInvocation:(NSInvocation *)invocation {
    return [_recordedInvocations filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(NSInvocation *candidate, NSDictionary *bindings) {
        return [self mock_invocation:candidate matchesInvocation:invocation];
    }]];
}

- (BOOL)mock_invocation:(NSInvocation *)invocation1 matchesInvocation:(NSInvocation *)invocation2 {
    // First check for obvious mismatches
    if (!(invocation1.selector == invocation2.selector && invocation1.target == invocation2.target)) {
        return NO;
    }
    
    // Check if parameter match
    NSMethodSignature *signature = invocation1.methodSignature;
    for (NSUInteger argIndex = 2; argIndex < [signature numberOfArguments]; argIndex++) {
        if (![self mock_argumentAtIndex:argIndex withType:[signature getArgumentTypeAtIndex:argIndex]
                    isEqualInInvocation:invocation1 andInvocation:invocation2])
        {
            return NO;
        }
    }
    
    // All good, we have a match
    return YES;
}

- (BOOL)mock_argumentAtIndex:(NSUInteger)index withType:(const char *)argType
         isEqualInInvocation:(NSInvocation *)invocation1 andInvocation:(NSInvocation *)invocation2
{
#define isType(t) (*argType == *@encode(t))

    if (isType(id)) {
        id value1, value2;
        [invocation1 getArgument:&value1 atIndex:index];
        [invocation2 getArgument:&value2 atIndex:index];
        return (value1 != nil ? [value1 isEqual:value2] : value2 == nil);
    } else {
        NSString *reason = [NSString stringWithFormat:@"Cannot match objects of type %s", argType];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
}


#pragma mark - Handling Unknown Methods

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self mock_recordInvocation:invocation];
}

@end
