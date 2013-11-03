//
//  MCKMockingContext.m
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKArgumentMatcherRecorder.h"
#import "MCKInvocationStubber.h"
#import "MCKFailureHandler.h"

#import "NSInvocation+MCKArgumentHandling.h"
#import <objc/runtime.h>

#import "MCKMockingContext+MCKFailureHandling.h"


@interface MCKMockingContext () <MCKVerificationSessionDelegate>

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
        _invocationVerifier = [[MCKInvocationVerifier alloc] init];
        _invocationVerifier.delegate = self;
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
    [self.invocationStubber finishRecordingStubGroup];
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

- (MCKStub *)activeStub {
    return [[self.invocationStubber recordedStubs] lastObject];
}


#pragma mark - Verification

- (void)beginVerificationWithTimeout:(NSTimeInterval)timeout {
    self.invocationVerifier.timeout = timeout;
    [self updateContextMode:MCKContextModeVerifying];
}

- (void)endVerification {
    [self updateContextMode:MCKContextModeRecording];
}

- (void)suspendVerification {
    [self updateContextMode:MCKContextModeRecording];
}

- (void)resumeVerification {
    [self updateContextMode:MCKContextModeVerifying];
}

- (id<MCKVerificationHandler>)verificationHandler {
    return self.invocationVerifier.verificationHandler;
}

- (void)setVerificationHandler:(id<MCKVerificationHandler>)verificationHandler {
    NSAssert((self.mode == MCKContextModeVerifying), @"Cannot set a verification handler outside verification mode");
    self.invocationVerifier.verificationHandler = verificationHandler;
}

- (void)verifyInvocation:(NSInvocation *)invocation {
    NSArray *matchers = [self.argumentMatcherRecorder collectAndReset];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
    [self.invocationVerifier verifyInvocations:self.mutableRecordedInvocations forPrototype:prototype];
}

- (void)verificationSession:(MCKInvocationVerifier *)session didFailWithReason:(NSString *)reason {
    [self.failureHandler handleFailureAtLocation:self.currentLocation withReason:reason];
}

- (void)verificationSessionDidEnd:(MCKInvocationVerifier *)session {
    [self endVerification];
}

- (void)verificationSessionWillProcessTimeout:(MCKInvocationVerifier *)session {
    [self suspendVerification];
}

- (void)verificationSessionDidProcessTimeout:(MCKInvocationVerifier *)session {
    [self resumeVerification];
}

@end
