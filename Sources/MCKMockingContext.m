//
//  MCKMockingContext.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"
#import "MCKInvocationRecorder.h"
#import "MCKInvocationStubber.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKStub.h"
#import "MCKInvocationMatcher.h"
#import "MCKArgumentMatcherCollection.h"
#import "MCKTypeEncodings.h"
#import "MCKSenTestFailureHandler.h"

#import <objc/runtime.h>


@interface MCKMockingContext ()

@property (nonatomic, readwrite, copy)   NSString *fileName;
@property (nonatomic, readwrite, assign) int       lineNumber;

@end


@implementation MCKMockingContext {
    MCKInvocationRecorder *_invocationRecorder;
    MCKInvocationStubber *_invocationStubber;
    MCKArgumentMatcherCollection *_argumentMatcherCollection;
}

static __weak id _CurrentContext = nil;


#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line {
    NSParameterAssert(testCase != nil);
    
    // Get the context or create a new one if necessary
    static const NSUInteger MCKMockingContextKey;
    MCKMockingContext *context = objc_getAssociatedObject(testCase, &MCKMockingContextKey);
    if (context == nil) {
        context = [[MCKMockingContext alloc] initWithTestCase:testCase];
        objc_setAssociatedObject(testCase, &MCKMockingContextKey, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // Update the file/line info
    context.fileName = file;
    context.lineNumber = line;
    
    return context;
}

+ (id)contextForTestCase:(id)testCase {
    return [self contextForTestCase:testCase fileName:nil lineNumber:0];
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
        _failureHandler = [[MCKSenTestFailureHandler alloc] initWithTestCase:testCase];
        
        MCKInvocationMatcher *invocationMatcher = [[MCKInvocationMatcher alloc] init];
        _invocationRecorder = [[MCKInvocationRecorder alloc] initWithInvocationMatcher:invocationMatcher];
        _invocationStubber = [[MCKInvocationStubber alloc] initWithInvocationMatcher:invocationMatcher];
        _argumentMatcherCollection = [[MCKArgumentMatcherCollection alloc] init];
        
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

- (void)updateContextMode:(MCKContextMode)newMode {
    _mode = newMode;
    [_argumentMatcherCollection resetAllMatchers];
    
    if (newMode == MCKContextModeVerifying) {
        _verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
    }
}

- (void)handleInvocation:(NSInvocation *)invocation {
    if (![_argumentMatcherCollection isValidForMethodSignature:invocation.methodSignature]) {
        [self failWithReason:@"When using argument matchers, all non-object arguments must be matchers"];
        return;
    }
    
    switch (_mode) {
        case MCKContextModeRecording: [self recordInvocation:invocation]; break;
        case MCKContextModeStubbing:  [self stubInvocation:invocation]; break;
        case MCKContextModeVerifying: [self verifyInvocation:invocation]; break;
            
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", _mode);
    }
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
    [_invocationStubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:_argumentMatcherCollection.primitiveArgumentMatchers];
    [_argumentMatcherCollection resetAllMatchers];
}

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation {
    return [_invocationStubber hasStubsRecordedForInvocation:invocation];
}

- (void)addStubAction:(id<MCKStubAction>)action {
    [_invocationStubber addActionToLastStub:action];
    [self updateContextMode:MCKContextModeRecording];
}


#pragma mark - Verification

- (void)verifyInvocation:(NSInvocation *)invocation {
    BOOL satisfied = NO;
    NSString *reason = nil;
    NSIndexSet *matchingIndexes = [_verificationHandler indexesMatchingInvocation:invocation
                                                             withArgumentMatchers:_argumentMatcherCollection
                                                             inInvocationRecorder:_invocationRecorder
                                                                        satisfied:&satisfied
                                                                   failureMessage:&reason];
    
    if (!satisfied) {
        [self failWithReason:[NSString stringWithFormat:@"verify: %@", (reason != nil ? reason : @"failed with an unknown reason")]];
    }
    [_invocationRecorder removeInvocationsAtIndexes:matchingIndexes];
    [self updateContextMode:MCKContextModeRecording];
}


#pragma mark - Argument Matching

- (NSArray *)primitiveArgumentMatchers {
    return [_argumentMatcherCollection.primitiveArgumentMatchers copy];
}

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if (_mode == MCKContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with whenCalling or verify"];
        return 0;
    }
    
    [_argumentMatcherCollection addPrimitiveArgumentMatcher:matcher];
    return [_argumentMatcherCollection lastPrimitiveArgumentMatcherIndex];
}

@end
