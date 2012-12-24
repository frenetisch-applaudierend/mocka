//
//  FakeVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "FakeVerificationHandler.h"
#import "MCKArgumentMatcherCollection.h"
#import "MCKInvocationCollection.h"


@implementation FakeVerificationHandler {
    NSIndexSet *_result;
    BOOL        _satisfied;
    NSString   *_failureMessage;
    FakeVerificationHandlerImplementation _implementation;
}


#pragma mark - Initialization

+ (id)handlerWhichFailsWithMessage:(NSString *)message {
    return [[self alloc] initWithResult:[NSIndexSet indexSet] isSatisfied:NO failureMessage:message implementation:nil];
}

+ (id)handlerWhichReturns:(NSIndexSet *)indexSet isSatisfied:(BOOL)isSatisfied {
    return [[self alloc] initWithResult:indexSet isSatisfied:isSatisfied failureMessage:nil implementation:nil];
}

+ (id)handlerWithImplementation:(FakeVerificationHandlerImplementation)impl {
    return [[self alloc] initWithResult:nil isSatisfied:NO failureMessage:nil implementation:impl];
}

- (id)initWithResult:(NSIndexSet *)result isSatisfied:(BOOL)satisfied failureMessage:(NSString *)message
      implementation:(FakeVerificationHandlerImplementation)impl
{
    if ((self = [super init])) {
        _result = [result copy];
        _satisfied = satisfied;
        _failureMessage = [message copy];
        _implementation = [impl copy];
    }
    return self;
}


#pragma mark - MCKVerificationHandler

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)argumentMatchers
                    inRecordedInvocations:(MCKInvocationCollection *)recordedInvocations
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    _lastInvocationPrototype = prototype;
    _lastArgumentMatchers = [argumentMatchers.primitiveArgumentMatchers copy];
    _lastRecordedInvocations = [recordedInvocations.allInvocations copy];
    _numberOfCalls++;
    
    if (_implementation != nil) {
        return _implementation(prototype, argumentMatchers, recordedInvocations, satisified, failureMessage);
    } else {
        if (satisified != NULL) *satisified = _satisfied;
        if (failureMessage != NULL) *failureMessage = [_failureMessage copy];
        return _result;
    }
}

@end
