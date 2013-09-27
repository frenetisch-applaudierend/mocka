//
//  MCKDefaultVerifier.m
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKDefaultVerifier.h"

#import "MCKVerificationHandler.h"
#import "MCKInvocationPrototype.h"
#import "MCKArgumentMatcherCollection.h"
#import "MCKFailureHandler.h"


@implementation MCKDefaultVerifier

@synthesize verificationHandler = _verificationHandler;
@synthesize failureHandler = _failureHandler;


#pragma mark - Verifying

- (MCKContextMode)verifyInvocation:(NSInvocation *)invocation
                      withMatchers:(MCKArgumentMatcherCollection *)matchers
             inRecordedInvocations:(NSMutableArray *)recordedInvocations
{
    BOOL satisified = NO;
    NSString *reason = nil;
    
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation
                                                                          argumentMatchers:matchers.primitiveArgumentMatchers];
    NSIndexSet *matchingIndexes = [_verificationHandler indexesOfInvocations:recordedInvocations
                                                        matchingForPrototype:prototype
                                                                   satisfied:&satisified
                                                              failureMessage:&reason];
    
    if (!satisified) {
        NSString *message = [NSString stringWithFormat:@"verify: %@", (reason != nil ? reason : @"failed with an unknown reason")];
        [_failureHandler handleFailureWithReason:message];
    }
    
    if (matchingIndexes != nil) {
        [recordedInvocations removeObjectsAtIndexes:matchingIndexes];
    }
    
    return MCKContextModeRecording;
}

@end
