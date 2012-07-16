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

#import <objc/runtime.h>
#import <SenTestingKit/SenTestingKit.h>


static const NSUInteger RGMockingContextKey;


@interface RGMockContext ()

@property (nonatomic, readwrite, copy)   NSString *fileName;
@property (nonatomic, readwrite, assign) int       lineNumber;

@end


@implementation RGMockContext {
    NSMutableArray *_recordedInvocations;
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

- (NSArray *)recordedInvocations {
    return [_recordedInvocations copy];
}

- (void)handleInvocation:(NSInvocation *)invocation {
    if (self.mode == RGMockContextModeRecording) {
        [self recordInvocation:invocation];
    } else if (self.mode == RGMockContextModeVerifying) {
        [self verifyInvocation:invocation];
    } else {
        NSAssert(NO, @"Oops, this context mode is unknown: %d", self.mode);
    }
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [_recordedInvocations addObject:invocation];
}

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
