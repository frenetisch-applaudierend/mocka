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
#import "RGMockTypeEncodings.h"

#import <objc/runtime.h>
#import <SenTestingKit/SenTestingKit.h>


@interface RGMockContext ()

@property (nonatomic, readwrite, copy)   NSString *fileName;
@property (nonatomic, readwrite, assign) int       lineNumber;

@end


@implementation RGMockContext {
    NSMutableArray *_recordedInvocations;
    NSMutableArray *_recordedStubbings;
    NSMutableArray *_nonObjectArgumentMatchers;
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
        _nonObjectArgumentMatchers = [NSMutableArray array];
        
        _CurrentContext = self;
    }
    return self;
}

- (id)init {
    return [self initWithTestCase:nil];
}


#pragma mark - Handling Failures

- (void)failWithReason:(NSString *)reason {
    if ([_testCase respondsToSelector:@selector(failWithException:)]) {
        [_testCase failWithException:[NSException failureInFile:_fileName atLine:_lineNumber withDescription:@"%@", reason]];
    } else {
        @throw [NSException failureInFile:_fileName atLine:_lineNumber withDescription:@"%@", reason];
    }
}


#pragma mark - Handling Invocations

- (BOOL)updateContextMode:(RGMockContextMode)newMode {
    _mode = newMode;
    [_nonObjectArgumentMatchers removeAllObjects];
    
    if (newMode == RGMockContextModeVerifying) {
        _verificationHandler = [RGMockDefaultVerificationHandler defaultHandler];
    }
    return YES;
}

- (void)handleInvocation:(NSInvocation *)invocation {
    if (![self eitherAllOrNoPrimitiveArgumentsHaveMatchersForInvocation:invocation]) {
        [self failWithReason:@"When using argument matchers, all non-object arguments must be matchers"];
    }
    
    switch (_mode) {
        case RGMockContextModeRecording: [self recordInvocation:invocation]; break;
        case RGMockContextModeStubbing:  [self createStubbingForInvocation:invocation]; break;
        case RGMockContextModeVerifying: [self verifyInvocation:invocation]; break;
            
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", _mode);
    }
}

- (BOOL)eitherAllOrNoPrimitiveArgumentsHaveMatchersForInvocation:(NSInvocation *)invocation {
    if ([_nonObjectArgumentMatchers count] == 0) return YES;
    
    NSUInteger matchersNeeded = 0;
    for (NSUInteger argIndex = 2; argIndex < [invocation.methodSignature numberOfArguments]; argIndex++) {
        if (![RGMockTypeEncodings isObjectType:[invocation.methodSignature getArgumentTypeAtIndex:argIndex]]) {
            matchersNeeded++;
        }
    }
    return ([_nonObjectArgumentMatchers count] == matchersNeeded);
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
        _currentStubbing = [[RGMockStubbing alloc] init];
        [_recordedStubbings addObject:_currentStubbing];
    }
    [_currentStubbing addInvocation:invocation withNonObjectArgumentMatchers:_nonObjectArgumentMatchers];
    [_nonObjectArgumentMatchers removeAllObjects];
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
                                                             withNonObjectArgumentMatchers:_nonObjectArgumentMatchers
                                                            inRecordedInvocations:_recordedInvocations
                                                                        satisfied:&satisfied];
    if (!satisfied) {
        [self failWithReason:@"Verify failed"];
    }
    [_recordedInvocations removeObjectsAtIndexes:matchingIndexes];
    [self updateContextMode:RGMockContextModeRecording];
}


#pragma mark - Argument Matching

- (UInt8)pushNonObjectArgumentMatcher:(id<RGMockArgumentMatcher>)matcher {
    if (_mode == RGMockContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with stub or verify"];
    }
    
    [_nonObjectArgumentMatchers addObject:matcher];
    return ([_nonObjectArgumentMatchers count] - 1);
}

@end
