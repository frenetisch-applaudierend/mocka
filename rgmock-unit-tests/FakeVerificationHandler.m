//
//  FakeVerificationHandler.m
//  rgmock
//
//  Created by Markus Gasser on 15.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "FakeVerificationHandler.h"

@implementation FakeVerificationHandler {
    NSIndexSet *_result;
    BOOL        _satisfied;
}

#pragma mark - Initialization

+ (id)handlerWhichReturns:(NSIndexSet *)indexSet isSatisfied:(BOOL)isSatisfied {
    return [[self alloc] initWithResult:indexSet isSatisfied:isSatisfied];
}

- (id)initWithResult:(NSIndexSet *)result isSatisfied:(BOOL)satisfied {
    if ((self = [super init])) {
        _result = [result copy];
        _satisfied = satisfied;
    }
    return self;
}


#pragma mark - RGMockVerificationHandler

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withNonObjectArgumentMatchers:(NSArray *)argumentMatchers
                    inRecordedInvocations:(NSArray *)recordedInvocations
                                satisfied:(BOOL *)satisified
{
    _lastInvocationPrototype = prototype;
    _lastArgumentMatchers = [argumentMatchers copy];
    _lastRecordedInvocations = [recordedInvocations copy];
    
    _numberOfCalls++;
    *satisified = _satisfied;
    return _result;
}

@end
