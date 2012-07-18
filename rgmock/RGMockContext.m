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


static const NSUInteger RGMockingContextKey;


@interface RGMockContext ()

@property (nonatomic, readwrite, copy)   NSString *fileName;
@property (nonatomic, readwrite, assign) int       lineNumber;

@end


@implementation RGMockContext {
    NSMutableArray *_recordedInvocations;
    NSMutableArray *_recordedStubbings;
}


#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line {
    NSParameterAssert(testCase != nil);
    
    // Get the context or create a new one if necessary
    RGMockContext *context = objc_getAssociatedObject(testCase, &RGMockingContextKey);
    if (context == nil) {
        context = [[RGMockContext alloc] init];
        objc_setAssociatedObject(testCase, &RGMockingContextKey, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // Update the file/line info
    context.fileName = file;
    context.lineNumber = line;
    
    return context;
}

- (id)init {
    if ((self = [super init])) {
        _recordedInvocations = [NSMutableArray array];
        _recordedStubbings = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Handling Failures

- (void)failWithReason:(NSString *)reason {
    @throw [NSException failureInFile:self.fileName atLine:self.lineNumber withDescription:@"%@", reason];
}


#pragma mark - Handling Invocations

- (BOOL)updateContextMode:(RGMockContextMode)newMode {
    _mode = newMode;
    if (newMode == RGMockContextModeVerifying) {
        self.verificationHandler = [RGMockDefaultVerificationHandler defaultHandler];
    }
    return YES;
}

- (void)handleInvocation:(NSInvocation *)invocation {
    switch (self.mode) {
        case RGMockContextModeRecording: [self recordInvocation:invocation]; break;
        case RGMockContextModeStubbing:  [self createStubbingForInvocation:invocation]; break;
        case RGMockContextModeVerifying: [self verifyInvocation:invocation]; break;
            
        default:
            NSAssert(NO, @"Oops, this context mode is unknown: %d", self.mode);
    }
}


#pragma mark - Recording

- (NSArray *)recordedInvocations {
    return [_recordedInvocations copy];
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [_recordedInvocations addObject:invocation];
    
    RGMockStubbing *stubbing = [self stubbingForInvocation:invocation];
    if (stubbing != nil) {
        [stubbing applyToInvocation:invocation];
    }
}


#pragma mark - Stubbing

- (void)createStubbingForInvocation:(NSInvocation *)invocation {
    [_recordedStubbings addObject:[[RGMockStubbing alloc] initWithInvocation:invocation]];
}

- (RGMockStubbing *)stubbingForInvocation:(NSInvocation *)invocation {
    for (RGMockStubbing *stubbing in _recordedStubbings) {
        if ([stubbing matchesForInvocation:invocation]) {
            return stubbing;
        }
    }
    return nil;
}

- (void)addStubAction:(id<RGMockStubAction>)action {
    [self updateContextMode:RGMockContextModeRecording];
    [[_recordedStubbings lastObject] addAction:action];
}


#pragma mark - Verification

- (void)verifyInvocation:(NSInvocation *)invocation {
    BOOL satisfied = NO;
    NSIndexSet *matchingIndexes = [self.verificationHandler indexesMatchingInvocation:invocation
                                                                inRecordedInvocations:self.recordedInvocations
                                                                            satisfied:&satisfied];
    if (!satisfied) {
        [self failWithReason:@"Verify failed"];
    }
    [_recordedInvocations removeObjectsAtIndexes:matchingIndexes];
}

@end
