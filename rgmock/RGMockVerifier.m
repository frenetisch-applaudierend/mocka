//
//  RGMockVerifier.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockVerifier.h"
#import "RGMockRecorder.h"

#import <SenTestingKit/SenTestingKit.h>


@interface RGMockVerifier () {
@private
    RGMockRecorder *_recorder;
}

- (void)mock_verificationFailedForInvocation:(NSInvocation *)invocation;

@end


@implementation RGMockVerifier

#pragma mark - Properties

@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;


#pragma mark - Initialization

- (id)initWithRecorder:(RGMockRecorder *)recorder {
    if ((self = [super init])) {
        _recorder = recorder;
    }
    return self;
}


#pragma mark - Capturing Method Calls

- (BOOL)respondsToSelector:(SEL)selector {
    return [_recorder respondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [_recorder methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    invocation.target = _recorder;
    NSArray *matchingInvocations = [_recorder mock_recordedInvocationsMatchingInvocation:invocation];
    if ([matchingInvocations count] == 0) {
        [self mock_verificationFailedForInvocation:invocation];
    }
}

- (void)mock_verificationFailedForInvocation:(NSInvocation *)invocation {
    NSString *reason = [NSString stringWithFormat:@"Could not verify invocation '%@'", invocation];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithUnsignedInteger:_lineNumber] forKey:SenTestLineNumberKey];
    if (_fileName != nil) {
        [userInfo setObject:_fileName forKey:SenTestFilenameKey];
    }
    
    @throw [NSException exceptionWithName:SenTestFailureException reason:reason userInfo:nil];
}

@end
