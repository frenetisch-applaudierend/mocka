//
//  RGMockingContext.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"
#import "RGMockVerificationHandler.h"
#import "RGMockDefaultVerificationHandler.h"
#import "RGMockStubbing.h"

#import <objc/runtime.h>
#import <SenTestingKit/SenTestingKit.h>


@interface RGMockContext ()

@property (nonatomic, readwrite, copy)   NSString *fileName;
@property (nonatomic, readwrite, assign) int       lineNumber;

@end


@implementation RGMockContext {
    NSMutableArray *_recordedInvocations;
    NSMutableArray *_recordedStubbings;
    NSMutableArray *_argumentMatchers;
    RGMockStubbing *_currentStubbing;
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
        _recordedInvocations = [NSMutableArray array];
        _recordedStubbings = [NSMutableArray array];
        _argumentMatchers = [NSMutableArray array];
        
        _CurrentContext = self;
    }
    return self;
}

- (id)init {
    return [self initWithTestCase:nil];
}


#pragma mark - Handling Failures

- (void)failWithReason:(NSString *)reason {
    @throw [NSException failureInFile:_fileName atLine:_lineNumber withDescription:@"%@", reason];
}


#pragma mark - Handling Invocations

- (BOOL)updateContextMode:(RGMockContextMode)newMode {
    _mode = newMode;
    if (newMode == RGMockContextModeVerifying) {
        _verificationHandler = [RGMockDefaultVerificationHandler defaultHandler];
    }
    return YES;
}

- (void)handleInvocation:(NSInvocation *)invocation {
    if ([_argumentMatchers count] > 0 && [_argumentMatchers count] != (invocation.methodSignature.numberOfArguments - 2)) {
        [self failWithReason:@"When using argument matchers, all arguments must be matchers"];
    }
    
    switch (_mode) {
        case RGMockContextModeRecording: [self recordInvocation:invocation]; break;
        case RGMockContextModeStubbing:  [self createStubbingForInvocation:invocation]; break;
        case RGMockContextModeVerifying: [self verifyInvocation:invocation]; break;
            
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", _mode);
    }
    
    // After a handled invocation we need to reset the matchers so they don't interfere with the next invocation
    [_argumentMatchers removeAllObjects];
}


#pragma mark - Recording

- (NSArray *)recordedInvocations {
    return [_recordedInvocations copy];
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    [_recordedInvocations addObject:invocation];
    
    RGMockStubbing *stubbing = [self stubbingForInvocation:invocation];
    if (stubbing != nil) {
        [stubbing applyToInvocation:invocation];
    }
}


#pragma mark - Stubbing

- (void)createStubbingForInvocation:(NSInvocation *)invocation {
    if (_currentStubbing == nil) {
        _currentStubbing = [[RGMockStubbing alloc] initWithInvocation:invocation];
        [_recordedStubbings addObject:_currentStubbing];
    } else {
        [_currentStubbing addInvocation:invocation];
    }
}

- (RGMockStubbing *)stubbingForInvocation:(NSInvocation *)invocation {
    for (RGMockStubbing *stubbing in [_recordedStubbings reverseObjectEnumerator]) {
        if ([stubbing matchesForInvocation:invocation]) {
            return stubbing;
        }
    }
    return nil;
}

- (void)addStubAction:(id<RGMockStubAction>)action {
    _currentStubbing = nil; // end of multiple stubs mode
    [self updateContextMode:RGMockContextModeRecording];
    [[_recordedStubbings lastObject] addAction:action];
}


#pragma mark - Verification

- (void)verifyInvocation:(NSInvocation *)invocation {
    BOOL satisfied = NO;
    NSIndexSet *matchingIndexes = [_verificationHandler indexesMatchingInvocation:invocation
                                                             withArgumentMatchers:_argumentMatchers
                                                            inRecordedInvocations:_recordedInvocations
                                                                        satisfied:&satisfied];
    if (!satisfied) {
        [self failWithReason:@"Verify failed"];
    }
    [_recordedInvocations removeObjectsAtIndexes:matchingIndexes];
}


#pragma mark - Argument Matching

- (UInt8)pushArgumentMatcher:(id<RGMockArgumentMatcher>)matcher {
    if (_mode == RGMockContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with stub or verify"];
    }
    
    [_argumentMatchers addObject:matcher];
    return ([_argumentMatchers count] - 1);
}

@end
