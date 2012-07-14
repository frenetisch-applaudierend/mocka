//
//  RGMockingContext.m
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockingContext.h"
#import "RGMockVerificationHandler.h"
#import "RGMockDefaultVerificationHandler.h"

#import <objc/runtime.h>
#import <SenTestingKit/SenTestingKit.h>


static const NSUInteger RGMockingContextKey;


@interface RGMockingContext ()

@property (nonatomic, readwrite, copy)   NSString *fileName;
@property (nonatomic, readwrite, assign) int       lineNumber;

@end


@implementation RGMockingContext {
    NSMutableArray *_recordedInvocations;
}

@synthesize mode = _mode;


#pragma mark - Getting a Context

+ (id)contextForTestCase:(id)testCase fileName:(NSString *)file lineNumber:(int)line {
    NSParameterAssert(testCase != nil);
    
    // Get the context or create a new one if necessary
    RGMockingContext *context = objc_getAssociatedObject(testCase, &RGMockingContextKey);
    if (context == nil) {
        context = [[RGMockingContext alloc] init];
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


#pragma mark - Handling Invocations

- (void)setMode:(RGMockingContextMode)newMode {
    _mode = newMode;
    if (newMode == RGMockingContextModeVerifying) {
        self.verificationHandler = [RGMockDefaultVerificationHandler defaultHandler];
    }
}

- (NSArray *)recordedInvocations {
    return [_recordedInvocations copy];
}

- (void)handleInvocation:(NSInvocation *)invocation {
    if (self.mode == RGMockingContextModeVerifying) {
        self.mode = RGMockingContextModeRecording;
        NSUInteger match = [_recordedInvocations indexOfObjectPassingTest:^BOOL(NSInvocation *candidate, NSUInteger idx, BOOL *stop) {
            return (candidate.target == invocation.target && candidate.selector == invocation.selector);
        }];
        if (match == NSNotFound) {
            @throw [NSException failureInFile:self.fileName atLine:self.lineNumber withDescription:@"Verify failed"];
        }
    } else {
        [_recordedInvocations addObject:invocation];
    }
}

@end
