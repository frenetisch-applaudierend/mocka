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
#import "MCKInvocationVerifier.h"
#import "MCKArgumentMatcherRecorder.h"
#import "MCKFailureHandler.h"
#import "MCKInvocationPrototype.h"

#import "NSInvocation+MCKArgumentHandling.h"
#import <objc/runtime.h>


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
        _invocationRecorder = [[MCKInvocationRecorder alloc] initWithMockingContext:self];
        _invocationStubber = [[MCKInvocationStubber alloc] init];
        _invocationVerifier = [[MCKInvocationVerifier alloc] initWithMockingContext:self];
        _argumentMatcherRecorder = [[MCKArgumentMatcherRecorder alloc] initWithMockingContext:self];
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


#pragma mark - Dispatching Invocations

- (void)updateContextMode:(MCKContextMode)newMode {
    NSAssert([self.argumentMatcherRecorder.argumentMatchers count] == 0, @"Should not contain any matchers at this point");
    _mode = newMode;
}

- (void)handleInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    
    NSString *reason = nil;
    if (![self.argumentMatcherRecorder isValidForMethodSignature:invocation.methodSignature reason:&reason]) {
        [self.argumentMatcherRecorder collectAndReset];
        [self failWithReason:@"%@", reason];
        return;
    }
    
    switch (self.mode) {
        case MCKContextModeRecording:
            [self.invocationRecorder recordInvocation:invocation];
            break;
        
        case MCKContextModeStubbing:
            [self.invocationStubber recordStubPrototype:[self prototypeForInvocation:invocation]];
            break;
        
        case MCKContextModeVerifying:
            [self.invocationVerifier verifyInvocationsForPrototype:[self prototypeForInvocation:invocation]];
            break;
            
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", self.mode);
    }
}

- (MCKInvocationPrototype *)prototypeForInvocation:(NSInvocation *)invocation {
    NSArray *matchers = [self.argumentMatcherRecorder collectAndReset];
    return [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
}


#pragma mark - Stubbing

- (MCKStub *)stubCalls:(void(^)(void))callBlock {
    NSParameterAssert(callBlock != nil);
    
    [self updateContextMode:MCKContextModeStubbing];
    
    callBlock();
    
    [self.invocationStubber finishRecordingStubGroup];
    [self updateContextMode:MCKContextModeRecording];
    
    return [[self.invocationStubber recordedStubs] lastObject];
}


#pragma mark - Verification

- (void)verifyCalls:(void(^)(void))callBlock usingCollector:(id<MCKVerificationResultCollector>)collector {
    NSParameterAssert(callBlock != nil);
    NSParameterAssert(collector != nil);
    
    [self updateContextMode:MCKContextModeVerifying];
    [self.invocationVerifier beginVerificationWithCollector:collector];
    callBlock();
    [self.invocationVerifier finishVerification];
    [self updateContextMode:MCKContextModeRecording];
}

- (void)useVerificationHandler:(id<MCKVerificationHandler>)handler {
    NSAssert((self.mode == MCKContextModeVerifying), @"Cannot set a verification handler outside verification mode");
    [self.invocationVerifier useVerificationHandler:handler];
}


#pragma mark - Argument Recording

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

- (void)clearArgumentMatchers {
    [self.argumentMatcherRecorder collectAndReset];
}

- (BOOL)checkCanPushArgumentMatcher {
    if (self.mode == MCKContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with stubbing or verification"];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Failure Handling

- (void)failWithReason:(NSString *)reason, ... {
    va_list ap;
    va_start(ap, reason);
    NSString *formattedReason = [[NSString alloc] initWithFormat:reason arguments:ap];
    [self.failureHandler handleFailureAtLocation:self.currentLocation withReason:formattedReason];
    va_end(ap);
}

@end
