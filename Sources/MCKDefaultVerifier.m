//
//  MCKDefaultVerifier.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKDefaultVerifier.h"
#import "MCKVerificationHandler.h"


@implementation MCKDefaultVerifier

- (MCKContextMode)verifyInvocation:(NSInvocation *)invocation
                      withMatchers:(MCKArgumentMatcherCollection *)matchers
             inRecordedInvocations:(MCKMutableInvocationCollection *)recordedInvocations
{
    BOOL satisified = NO;
    NSString *reason = nil;
    NSIndexSet *matchingIndexes = [_verificationHandler indexesMatchingInvocation:invocation withArgumentMatchers:matchers
                                                            inRecordedInvocations:recordedInvocations
                                                                        satisfied:&satisified failureMessage:&reason];
    
    if (!satisified) {
        NSString *message = [NSString stringWithFormat:@"verify: %@", (reason != nil ? reason : @"failed with an unknown reason")];
        [_failureHandler handleFailureWithReason:message];
    }
    
    [recordedInvocations removeInvocationsAtIndexes:matchingIndexes];
    
    return MCKContextModeRecording;
}

@end
