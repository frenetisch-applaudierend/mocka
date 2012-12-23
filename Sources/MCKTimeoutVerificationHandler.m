//
//  MCKTimeoutVerificationHandler.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKTimeoutVerificationHandler.h"


@implementation MCKTimeoutVerificationHandler

#pragma mark - Initialization

+ (id)timeoutHandlerWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler {
    return [[self alloc] initWithTimeout:timeout currentVerificationHandler:handler];
}

- (id)initWithTimeout:(NSTimeInterval)timeout currentVerificationHandler:(id<MCKVerificationHandler>)handler {
    if ((self = [super init])) {
    }
    return self;
}


#pragma mark - Handling Verification

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                     withArgumentMatchers:(MCKArgumentMatcherCollection *)matchers
                    inRecordedInvocations:(MCKInvocationCollection *)recordedInvocations
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage
{
    return nil;
}

@end
