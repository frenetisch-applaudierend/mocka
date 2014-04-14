//
//  FakeVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "FakeVerificationHandler.h"


@interface FakeVerificationHandler ()

@property (nonatomic, readonly) NSMutableArray *recordedCalls;

@end


@implementation FakeVerificationHandler

#pragma mark - Initialization

+ (instancetype)dummy {
    return [self handlerWhichSucceeds];
}

+ (instancetype)handlerWhichSucceeds {
    MCKVerificationResult* result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSet]];
    return [[self alloc] initWithResult:result implementation:nil];
}

+ (instancetype)handlerWhichSucceedsWithMatches:(NSIndexSet *)matches {
    MCKVerificationResult* result = [MCKVerificationResult successWithMatchingIndexes:matches];
    return [[self alloc] initWithResult:result implementation:nil];
}

+ (instancetype)handlerWhichFailsWithMatches:(NSIndexSet *)matches reason:(NSString *)reason {
    MCKVerificationResult* result = [MCKVerificationResult failureWithReason:reason matchingIndexes:matches];
    return [[self alloc] initWithResult:result implementation:nil];
}

+ (instancetype)handlerWhichFailsWithReason:(NSString *)reason {
    MCKVerificationResult* result = [MCKVerificationResult failureWithReason:reason matchingIndexes:[NSIndexSet indexSet]];
    return [[self alloc] initWithResult:result implementation:nil];
}

+ (instancetype)handlerWithResult:(MCKVerificationResult *)result {
    return [[self alloc] initWithResult:result implementation:nil];
}

+ (instancetype)handlerWithImplementation:(MCKVerificationResult*(^)(MCKInvocationPrototype*, NSArray*))implementation {
    return [[self alloc] initWithResult:nil implementation:implementation];
}

- (instancetype)initWithResult:(MCKVerificationResult *)result
                implementation:(MCKVerificationResult*(^)(MCKInvocationPrototype*, NSArray*))implementation
{
    if ((self = [super init])) {
        _result = result;
        _implementation = [implementation copy];
        _recordedCalls = [NSMutableArray array];
    }
    return self;
}


#pragma mark - MCKVerificationHandler

- (NSArray *)calls {
    return [self.recordedCalls copy];
}

- (MCKVerificationResult *)verifyInvocations:(NSArray *)invocations forPrototype:(MCKInvocationPrototype *)prototype {
    MCKVerificationResult *result = (self.implementation != nil ? self.implementation(prototype, invocations) : self.result);
    FakeVerificationHandlerCall *call =
    [FakeVerificationHandlerCall callWithPrototype:prototype invocations:invocations result:result];
    [self.recordedCalls addObject:call];
    return result;
}

- (BOOL)mustAwaitTimeoutForResult:(MCKVerificationResult *)result
{
    return NO;
}

@end


@implementation FakeVerificationHandlerCall

+ (instancetype)callWithPrototype:(MCKInvocationPrototype *)prototype
                      invocations:(NSArray *)invocations
                           result:(MCKVerificationResult *)result
{
    return [[self alloc] initWithPrototype:prototype invocations:invocations result:result];
}

- (instancetype)initWithPrototype:(MCKInvocationPrototype *)prototype
                      invocations:(NSArray *)invocations
                           result:(MCKVerificationResult *)result
{
    if ((self = [super init])) {
        _prototype = prototype;
        _invocations = [invocations copy];
        _result = result;
    }
    return self;
}

@end
