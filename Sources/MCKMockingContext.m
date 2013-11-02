//
//  MCKMockingContext.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"
#import "MCKVerificationSession.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKArgumentMatcherRecorder.h"
#import "MCKInvocationStubber.h"
#import "MCKFailureHandler.h"

#import "NSInvocation+MCKArgumentHandling.h"
#import <objc/runtime.h>


@interface MCKMockingContext () <MCKVerificationSessionDelegate>

@property (nonatomic, readwrite, strong) MCKVerificationSession *verificationSession;
@property (nonatomic, readonly) NSMutableArray *mutableRecordedInvocations;

@end


@implementation MCKMockingContext

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

static __weak id _CurrentContext = nil;

+ (instancetype)currentContext {
    if (_CurrentContext == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Cannot use this method before a context was created using +contextForTestCase:"
                                     userInfo:nil];
    }
    return _CurrentContext;
}

+ (void)setCurrentContext:(MCKMockingContext *)context {
    _CurrentContext = context;
}

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


#pragma mark - Initialization

- (instancetype)initWithTestCase:(id)testCase {
    if ((self = [super init])) {
        _mutableRecordedInvocations = [NSMutableArray array];
        _invocationStubber = [[MCKInvocationStubber alloc] init];
        _argumentMatcherRecorder = [[MCKArgumentMatcherRecorder alloc] init];
        _failureHandler = [MCKFailureHandler failureHandlerForTestCase:testCase];
        
        [[self class] setCurrentContext:self];
    }
    return self;
}

- (instancetype)init {
    return [self initWithTestCase:nil];
}

- (void)dealloc {
    [[self class] setCurrentContext:nil];
}


#pragma mark - Context Data

- (void)updateFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber {
    [self.failureHandler updateFileName:fileName lineNumber:lineNumber];
}


#pragma mark - Handling Invocations

- (void)updateContextMode:(MCKContextMode)newMode {
    NSAssert([self.argumentMatcherRecorder.argumentMatchers count] == 0, @"Should not contain any matchers at this point");
    _mode = newMode;
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
            NSAssert(NO, @"Oops, this context mode is unknown: %d", self.mode);
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

- (void)beginStubbing {
    [self updateContextMode:MCKContextModeStubbing];
}

- (void)endStubbing {
    [self updateContextMode:MCKContextModeRecording];
}

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

- (MCKStub *)activeStub {
    return [[self.invocationStubber recordedStubs] lastObject];
}


#pragma mark - Verification

- (void)beginVerificationWithTimeout:(NSTimeInterval)timeout {
    self.verificationSession = [[MCKVerificationSession alloc] initWithTimeout:timeout];
    self.verificationSession.delegate = self;
    [self updateContextMode:MCKContextModeVerifying];
}

- (void)endVerification {
    self.verificationSession = nil;
    [self updateContextMode:MCKContextModeRecording];
}

- (void)suspendVerification {
    [self updateContextMode:MCKContextModeRecording];
}

- (void)resumeVerification {
    [self updateContextMode:MCKContextModeVerifying];
}

- (id<MCKVerificationHandler>)verificationHandler {
    return self.verificationSession.verificationHandler;
}

- (void)setVerificationHandler:(id<MCKVerificationHandler>)verificationHandler {
    NSAssert(self.verificationSession != nil, @"Cannot set a verification handler outside a verification session");
    self.verificationSession.verificationHandler = verificationHandler;
}

- (void)verifyInvocation:(NSInvocation *)invocation {
    NSArray *matchers = [self.argumentMatcherRecorder collectAndReset];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
    [self.verificationSession verifyInvocations:self.mutableRecordedInvocations forPrototype:prototype];
}

- (void)verificationSession:(MCKVerificationSession *)session didFailWithReason:(NSString *)reason {
    [self.failureHandler handleFailureWithReason:reason];
}

- (void)verificationSessionDidEnd:(MCKVerificationSession *)session {
    [self endVerification];
}

- (void)verificationSessionWillProcessTimeout:(MCKVerificationSession *)session {
    [self suspendVerification];
}

- (void)verificationSessionDidProcessTimeout:(MCKVerificationSession *)session {
    [self resumeVerification];
}


#pragma mark - Argument Matching

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if (![self checkCanPushArgumentMatcher]) {
        return 0;
    }
    return [self.argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
}

- (UInt8)pushObjectArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if (![self checkCanPushArgumentMatcher]) {
        return 0;
    }
    return [self.argumentMatcherRecorder addObjectArgumentMatcher:matcher];
}

- (BOOL)checkCanPushArgumentMatcher {
    if (self.mode == MCKContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with stubbing or verification"];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Handling Failures

- (void)failWithReason:(NSString *)reason, ... {
    va_list ap;
    va_start(ap, reason);
    [self.failureHandler handleFailureWithReason:[[NSString alloc] initWithFormat:reason arguments:ap]];
    va_end(ap);
}


@end
