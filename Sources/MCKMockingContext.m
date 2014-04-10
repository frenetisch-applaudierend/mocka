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
#import "MCKAPIMisuse.h"
#import "NSInvocation+MCKArgumentHandling.h"


@interface MCKMockingContext ()

@property (nonatomic, readonly) NSMutableSet *registeredMocks;

@end

@implementation MCKMockingContext

#pragma mark - Startup

+ (void)initialize
{
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

static id _CurrentContext = nil;

+ (void)setCurrentContext:(MCKMockingContext *)context
{
    _CurrentContext = context;
}

+ (instancetype)currentContext
{
    NSAssert(_CurrentContext != nil, @"Need a context at this point");
    return _CurrentContext;
}


#pragma mark - Initialization

- (instancetype)initWithTestCase:(id)testCase
{
    if ((self = [super init])) {
        _invocationRecorder = [[MCKInvocationRecorder alloc] initWithMockingContext:self];
        _invocationStubber = [[MCKInvocationStubber alloc] init];
        _invocationVerifier = [[MCKInvocationVerifier alloc] initWithMockingContext:self];
        _argumentMatcherRecorder = [[MCKArgumentMatcherRecorder alloc] init];
        _failureHandler = [MCKFailureHandler failureHandlerForTestCase:testCase];
        
        _registeredMocks = [NSMutableSet set];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithTestCase:nil];
}


#pragma mark - Registering Mocks

- (void)registerMockObject:(id)mockObject
{
    NSParameterAssert(mockObject != nil);
    
    [self.registeredMocks addObject:mockObject];
}


#pragma mark - Dispatching Invocations

- (void)updateContextMode:(MCKContextMode)newMode
{
    NSAssert([self.argumentMatcherRecorder.argumentMatchers count] == 0, @"Should not contain any matchers at this point");
    _mode = newMode;
}

- (void)handleInvocation:(NSInvocation *)invocation
{
    [invocation retainArguments];
    
    [self checkArgumentMatchersForInvocation:invocation];
    
    MCKInvocationPrototype *prototype = [self prototypeForInvocation:invocation];
    switch (self.mode) {
        case MCKContextModeRecording: [self.invocationRecorder recordInvocationFromPrototype:prototype]; break;
        case MCKContextModeStubbing:  [self.invocationStubber recordStubPrototype:prototype]; break;
        case MCKContextModeVerifying: [self.invocationVerifier verifyInvocationsForPrototype:prototype]; break;
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", self.mode);
    }
}

- (void)checkArgumentMatchersForInvocation:(NSInvocation *)invocation
{
    if (self.mode == MCKContextModeRecording && [self.argumentMatcherRecorder.argumentMatchers count] > 0) {
        MCKAPIMisuse(@"Argument matchers are only valid when stubbing or verifying");
    }
    [self.argumentMatcherRecorder validateForMethodSignature:invocation.methodSignature];
}

- (MCKInvocationPrototype *)prototypeForInvocation:(NSInvocation *)invocation
{
    NSArray *matchers = [self.argumentMatcherRecorder collectAndReset];
    return [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
}


#pragma mark - Stubbing

- (MCKStub *)stubCalls:(void(^)(void))callBlock
{
    NSParameterAssert(callBlock != nil);
    
    [self updateContextMode:MCKContextModeStubbing];
    
    callBlock();
    
    [self.invocationStubber finishRecordingStubGroup];
    [self updateContextMode:MCKContextModeRecording];
    
    return [[self.invocationStubber recordedStubs] lastObject];
}


#pragma mark - Failure Handling

- (void)failWithReason:(NSString *)reason, ...
{
    va_list ap;
    va_start(ap, reason);
    NSString *formattedReason = [[NSString alloc] initWithFormat:reason arguments:ap];
    [self.failureHandler handleFailureAtLocation:self.currentLocation withReason:formattedReason];
    va_end(ap);
}

@end
