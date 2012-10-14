//
//  RGMockingContext.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"
#import "RGMockInvocationRecorder.h"
#import "RGMockInvocationStubber.h"
#import "RGMockVerificationHandler.h"
#import "RGMockDefaultVerificationHandler.h"
#import "RGMockStub.h"
#import "RGMockInvocationMatcher.h"
#import "RGMockArgumentMatcherCollection.h"
#import "RGMockTypeEncodings.h"
#import "RGMockSenTestFailureHandler.h"

#import <objc/runtime.h>


@interface RGMockContext ()

@property (nonatomic, readwrite, copy)   NSString *fileName;
@property (nonatomic, readwrite, assign) int       lineNumber;

@end


@implementation RGMockContext {
    RGMockInvocationRecorder *_invocationRecorder;
    RGMockInvocationStubber *_invocationStubber;
    RGMockArgumentMatcherCollection *_argumentMatcherCollection;
}

static __weak id _CurrentContext = nil;


#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line {
    NSParameterAssert(testCase != nil);
    
    // Get the context or create a new one if necessary
    static const NSUInteger RGMockingContextKey;
    RGMockContext *context = objc_getAssociatedObject(testCase, &RGMockingContextKey);
    if (context == nil) {
        context = [[RGMockContext alloc] initWithTestCase:testCase];
        objc_setAssociatedObject(testCase, &RGMockingContextKey, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // Update the file/line info
    context.fileName = file;
    context.lineNumber = line;
    
    return context;
}

+ (id)currentContext {
    if (_CurrentContext == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"This method cannot be used before a context was created using +contextForTestCase:fileName:lineNumber:"
                                     userInfo:nil];
    }
    return _CurrentContext;
}


#pragma mark - Initialization

- (id)initWithTestCase:(id)testCase {
    if ((self = [super init])) {
        _testCase = testCase;
        _failureHandler = [[RGMockSenTestFailureHandler alloc] initWithTestCase:testCase];
        
        RGMockInvocationMatcher *invocationMatcher = [[RGMockInvocationMatcher alloc] init];
        _invocationRecorder = [[RGMockInvocationRecorder alloc] initWithInvocationMatcher:invocationMatcher];
        _invocationStubber = [[RGMockInvocationStubber alloc] initWithInvocationMatcher:invocationMatcher];
        _argumentMatcherCollection = [[RGMockArgumentMatcherCollection alloc] init];
        
        _CurrentContext = self;
    }
    return self;
}

- (id)init {
    return [self initWithTestCase:nil];
}


#pragma mark - Handling Failures

- (void)failWithReason:(NSString *)reason {
    [_failureHandler handleFailureInFile:_fileName atLine:_lineNumber withReason:reason];
}


#pragma mark - Handling Invocations

- (void)updateContextMode:(RGMockContextMode)newMode {
    _mode = newMode;
    [_argumentMatcherCollection.nonObjectArgumentMatchers removeAllObjects];
    
    if (newMode == RGMockContextModeVerifying) {
        _verificationHandler = [RGMockDefaultVerificationHandler defaultHandler];
    }
}

- (void)handleInvocation:(NSInvocation *)invocation {
    if (![self eitherAllOrNoPrimitiveArgumentsHaveMatchersForInvocation:invocation]) {
        [self failWithReason:@"When using argument matchers, all non-object arguments must be matchers"];
        return;
    }
    
    switch (_mode) {
        case RGMockContextModeRecording: [self recordInvocation:invocation]; break;
        case RGMockContextModeStubbing:  [self stubInvocation:invocation]; break;
        case RGMockContextModeVerifying: [self verifyInvocation:invocation]; break;
            
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", _mode);
    }
}

- (BOOL)eitherAllOrNoPrimitiveArgumentsHaveMatchersForInvocation:(NSInvocation *)invocation {
    if ([_argumentMatcherCollection.nonObjectArgumentMatchers count] == 0) return YES;
    
    NSUInteger matchersNeeded = 0;
    for (NSUInteger argIndex = 2; argIndex < [invocation.methodSignature numberOfArguments]; argIndex++) {
        if (![RGMockTypeEncodings isObjectType:[invocation.methodSignature getArgumentTypeAtIndex:argIndex]]) {
            matchersNeeded++;
        }
    }
    return ([_argumentMatcherCollection.nonObjectArgumentMatchers count] == matchersNeeded);
}


#pragma mark - Recording

- (NSArray *)recordedInvocations {
    return _invocationRecorder.recordedInvocations;
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [_invocationRecorder recordInvocation:invocation];
    [_invocationStubber applyStubsForInvocation:invocation];
}


#pragma mark - Stubbing

- (void)stubInvocation:(NSInvocation *)invocation {
    [_invocationStubber recordStubInvocation:invocation withNonObjectArgumentMatchers:_argumentMatcherCollection.nonObjectArgumentMatchers];
    [_argumentMatcherCollection.nonObjectArgumentMatchers removeAllObjects];
}

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation {
    return [_invocationStubber hasStubsRecordedForInvocation:invocation];
}

- (void)addStubAction:(id<RGMockStubAction>)action {
    [_invocationStubber addActionToLastStub:action];
    [self updateContextMode:RGMockContextModeRecording];
}


#pragma mark - Verification

- (void)verifyInvocation:(NSInvocation *)invocation {
    BOOL satisfied = NO;
    NSString *reason = nil;
    NSIndexSet *matchingIndexes = [_verificationHandler indexesMatchingInvocation:invocation
                                                    withNonObjectArgumentMatchers:_argumentMatcherCollection.nonObjectArgumentMatchers
                                                             inInvocationRecorder:_invocationRecorder
                                                                        satisfied:&satisfied
                                                                   failureMessage:&reason];
    
    if (!satisfied) {
        [self failWithReason:[NSString stringWithFormat:@"verify: %@", (reason != nil ? reason : @"failed with an unknown reason")]];
    }
    [_invocationRecorder removeInvocationsAtIndexes:matchingIndexes];
    [self updateContextMode:RGMockContextModeRecording];
}


#pragma mark - Argument Matching

- (NSArray *)nonObjectArgumentMatchers {
    return [_argumentMatcherCollection.nonObjectArgumentMatchers copy];
}

- (UInt8)pushNonObjectArgumentMatcher:(id<RGMockArgumentMatcher>)matcher {
    if (_mode == RGMockContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with whenCalling or verify"];
        return 0;
    }
    
    [_argumentMatcherCollection.nonObjectArgumentMatchers addObject:matcher];
    return ([_argumentMatcherCollection.nonObjectArgumentMatchers count] - 1);
}

@end
