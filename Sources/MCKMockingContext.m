//
//  MCKMockingContext.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"
#import "MCKDefaultVerifier.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKInvocationPrototype.h"
#import "MCKArgumentMatcherRecorder.h"
#import "MCKInvocationStubber.h"
#import "MCKFailureHandler.h"

#import "NSInvocation+MCKArgumentHandling.h"
#import <objc/runtime.h>


@interface MCKMockingContext ()

@property (nonatomic, readonly) NSMutableArray *mutableRecordedInvocations;
@end


@implementation MCKMockingContext

static __weak id _CurrentContext = nil;


#pragma mark - Startup

+ (void)initialize {
    if (!(self == [MCKMockingContext class])) {
        return;
    }
    
    // Check that categories were loaded
    if (![NSInvocation instancesRespondToSelector:@selector(mck_sizeofParameterAtIndex:)]) {
        NSLog(@"****************************************************************************");
        NSLog(@"* Mocka could not find required category methods                           *");
        NSLog(@"* Make sure you have \"-ObjC\" in your testing target's \"Other Linker Flags\" *");
        NSLog(@"************************************************************************");
        abort();
    }
}


#pragma mark - Getting a Context

+ (instancetype)contextForTestCase:(id)testCase {
    NSParameterAssert(testCase != nil);
    
    // Get the context or create a new one if necessary
    static const NSUInteger MCKMockingContextKey;
    MCKMockingContext *context = objc_getAssociatedObject(testCase, &MCKMockingContextKey);
    if (context == nil) {
        context = [[MCKMockingContext alloc] initWithTestCase:testCase];
        objc_setAssociatedObject(testCase, &MCKMockingContextKey, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return context;
}

+ (instancetype)currentContext {
    if (_CurrentContext == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"This method cannot be used before a context was created using +contextForTestCase:fileName:lineNumber:"
                                     userInfo:nil];
    }
    return _CurrentContext;
}


#pragma mark - Initialization

- (instancetype)initWithTestCase:(id)testCase {
    if ((self = [super init])) {
        _failureHandler = [MCKFailureHandler failureHandlerForTestCase:testCase];
        _verificationHandler = [MCKDefaultVerificationHandler defaultHandler];
        
        _mutableRecordedInvocations = [NSMutableArray array];
        _invocationStubber = [[MCKInvocationStubber alloc] init];
        _argumentMatcherRecorder = [[MCKArgumentMatcherRecorder alloc] init];
        
        _CurrentContext = self;
        
        [self setVerifier:[[MCKDefaultVerifier alloc] init]];
    }
    return self;
}

- (instancetype)init {
    return [self initWithTestCase:nil];
}

- (void)dealloc {
    _CurrentContext = nil;
}


#pragma mark - Context Data

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber {
    [self.failureHandler updateFileName:fileName lineNumber:lineNumber];
}


#pragma mark - Handling Failures

- (void)setFailureHandler:(MCKFailureHandler *)failureHandler {
    _failureHandler = failureHandler;
    self.verifier.failureHandler = failureHandler;
}

- (void)failWithReason:(NSString *)reason, ... {
    va_list ap;
    va_start(ap, reason);
    [self.failureHandler handleFailureWithReason:[[NSString alloc] initWithFormat:reason arguments:ap]];
    va_end(ap);
}


#pragma mark - Handling Invocations

- (void)updateContextMode:(MCKContextMode)newMode {
    _mode = newMode;
    
    NSAssert([self.argumentMatcherRecorder.argumentMatchers count] == 0, @"Should not contain any matchers at this point");
    
    if (newMode == MCKContextModeVerifying) {
        [self setVerificationHandler:[MCKDefaultVerificationHandler defaultHandler]];
    }
}

- (void)handleInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    
    NSString *reason = nil;
    if (![self.argumentMatcherRecorder isValidForMethodSignature:invocation.methodSignature reason:&reason]) {
        [self failWithReason:@"%@", reason];
        return;
    }
    
    switch (self.mode) {
        case MCKContextModeRecording: [self recordInvocation:invocation]; break;
        case MCKContextModeStubbing:  [self stubInvocation:invocation]; break;
        case MCKContextModeVerifying: [self verifyInvocation:invocation]; break;
            
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", _mode);
    }
}


#pragma mark - Recording

- (NSArray *)recordedInvocations {
    return [self.mutableRecordedInvocations copy];
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [self.mutableRecordedInvocations addObject:invocation];
    [self.invocationStubber applyStubsForInvocation:invocation];
}


#pragma mark - Stubbing

- (void)stubInvocation:(NSInvocation *)invocation {
    NSArray *matchers = [self.argumentMatcherRecorder collectAndReset];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
    [self.invocationStubber recordStubPrototype:prototype];
}

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation {
    return [self.invocationStubber hasStubsRecordedForInvocation:invocation];
}

- (void)addStubAction:(id<MCKStubAction>)action {
    [self.invocationStubber addActionToLastStub:action];
    [self updateContextMode:MCKContextModeRecording];
}


#pragma mark - Verification

- (void)setVerifier:(id<MCKVerifier>)verifier {
    _verifier = verifier;
    verifier.failureHandler = self.failureHandler;
    verifier.verificationHandler = self.verificationHandler;
}

- (void)setVerificationHandler:(id<MCKVerificationHandler>)verificationHandler {
    _verificationHandler = verificationHandler;
    self.verifier.verificationHandler = verificationHandler;
}

- (void)verifyInvocation:(NSInvocation *)invocation {
    NSArray *matchers = [self.argumentMatcherRecorder collectAndReset];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
    MCKContextMode newMode = [self.verifier verifyPrototype:prototype invocations:self.mutableRecordedInvocations];
    [self updateContextMode:newMode];
}


#pragma mark - Argument Matching

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if (self.mode == MCKContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with whenCalling or verify"];
        return 0;
    }
    return [self.argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
}

@end
