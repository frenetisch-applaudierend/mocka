//
//  CannedVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 01.11.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "CannedVerificationHandler.h"
#import "MCKInvocationRecorder.h"
#import "MCKArgumentMatcherCollection.h"


@implementation CannedVerificationHandler {
    NSIndexSet *_result;
    BOOL        _satisfied;
    NSString   *_failureMessage;
}

#pragma mark - Initialization

+ (id)handlerWhichFailsWithMessage:(NSString *)message {
    return [[self alloc] initWithResult:[NSIndexSet indexSet] isSatisfied:NO failureMessage:message];
}

+ (id)handlerWhichReturns:(NSIndexSet *)indexSet isSatisfied:(BOOL)isSatisfied {
    return [[self alloc] initWithResult:indexSet isSatisfied:isSatisfied failureMessage:nil];
}

- (id)initWithResult:(NSIndexSet *)result isSatisfied:(BOOL)satisfied failureMessage:(NSString *)message {
    if ((self = [super init])) {
        _result = [result copy];
        _satisfied = satisfied;
        _failureMessage = [message copy];
    }
    return self;
}

- (id)init {
    return [self initWithResult:[NSIndexSet indexSet] isSatisfied:YES failureMessage:nil];
}


#pragma mark - MCKVerificationHandler

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)argumentMatchers
                     inInvocationRecorder:(MCKInvocationRecorder *)recorder
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    _lastInvocationPrototype = prototype;
    _lastArgumentMatchers = [argumentMatchers.primitiveArgumentMatchers copy];
    _lastRecordedInvocations = [recorder.recordedInvocations copy];
    _numberOfCalls++;
    
    if (satisified != NULL) *satisified = _satisfied;
    if (failureMessage != NULL) *failureMessage = [_failureMessage copy];
    return _result;
}

@end
