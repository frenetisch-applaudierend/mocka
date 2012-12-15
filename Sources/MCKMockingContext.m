//
//  MCKMockingContext.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"
#import "MCKVerifier.h"
#import "MCKDefaultVerifier.h"
#import "MCKOrderedVerifier.h"
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


@implementation MCKMockingContext

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
    [context.failureHandler updateFileName:file lineNumber:line];
    
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
        _failureHandler = [[MCKSenTestFailureHandler alloc] initWithTestCase:testCase];
        _verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
        
        _recordedInvocations = [[MCKMutableInvocationCollection alloc] initWithInvocationMatcher:[MCKInvocationMatcher matcher]];
        _invocationStubber = [[MCKInvocationStubber alloc] initWithInvocationMatcher:[MCKInvocationMatcher matcher]];
        _argumentMatchers = [[MCKArgumentMatcherCollection alloc] init];
        
        _CurrentContext = self;
        
        [self setVerifier:[[MCKDefaultVerifier alloc] init]];
    }
    return self;
}

- (id)init {
    return [self initWithTestCase:nil];
}

- (void)dealloc {
    _CurrentContext = nil;
}


#pragma mark - Handling Failures

- (void)setFailureHandler:(id<MCKFailureHandler>)failureHandler {
    _failureHandler = failureHandler;
    _verifier.failureHandler = failureHandler;
}

- (void)failWithReason:(NSString *)reason, ... {
    va_list ap;
    va_start(ap, reason);
    [_failureHandler handleFailureWithReason:[[NSString alloc] initWithFormat:reason arguments:ap]];
    va_end(ap);
}


#pragma mark - Handling Invocations

- (void)updateContextMode:(MCKContextMode)newMode {
    _mode = newMode;
    [_argumentMatchers resetAllMatchers];
    
    if (newMode == MCKContextModeVerifying) {
        [self setVerificationHandler:[MCKDefaultVerificationHandler defaultHandler]];
    }
}

- (void)handleInvocation:(NSInvocation *)invocation {
    if (![_argumentMatchers isValidForMethodSignature:invocation.methodSignature]) {
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

- (void)recordInvocation:(NSInvocation *)invocation {
    [_recordedInvocations addInvocation:invocation];
    [_invocationStubber applyStubsForInvocation:invocation];
}


#pragma mark - Stubbing

- (void)stubInvocation:(NSInvocation *)invocation {
    [_invocationStubber recordStubInvocation:invocation withPrimitiveArgumentMatchers:_argumentMatchers.primitiveArgumentMatchers];
    [_argumentMatchers resetAllMatchers];
}

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation {
    return [_invocationStubber hasStubsRecordedForInvocation:invocation];
}

- (void)addStubAction:(id<MCKStubAction>)action {
    [_invocationStubber addActionToLastStub:action];
    [self updateContextMode:MCKContextModeRecording];
}


#pragma mark - Verification

- (void)setVerifier:(id<MCKVerifier>)verifier {
    _verifier = verifier;
    _verifier.failureHandler = _failureHandler;
    _verifier.verificationHandler = _verificationHandler;
}

- (void)setVerificationHandler:(id<MCKVerificationHandler>)verificationHandler {
    _verificationHandler = verificationHandler;
    _verifier.verificationHandler = verificationHandler;
}

- (void)verifyInvocation:(NSInvocation *)invocation {
    MCKContextMode newMode = [_verifier verifyInvocation:invocation withMatchers:_argumentMatchers inRecordedInvocations:_recordedInvocations];
    [self updateContextMode:newMode];
}


#pragma mark - Argument Matching

- (NSArray *)primitiveArgumentMatchers {
    return [_argumentMatchers.primitiveArgumentMatchers copy];
}

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if (_mode == MCKContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with whenCalling or verify"];
        return 0;
    }
    
    [_argumentMatchers addPrimitiveArgumentMatcher:matcher];
    return [_argumentMatchers lastPrimitiveArgumentMatcherIndex];
}

@end
