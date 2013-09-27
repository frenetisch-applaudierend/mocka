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

- (MCKContextMode)verifyPrototype:(MCKInvocationPrototype *)prototype invocations:(NSMutableArray *)invocations {
    BOOL satisified = NO;
    NSString *reason = nil;
    
    NSIndexSet *matchingIndexes = [_verificationHandler indexesOfInvocations:invocations
                                                        matchingForPrototype:prototype
                                                                   satisfied:&satisified
                                                              failureMessage:&reason];
    
    if (!satisified) {
        NSString *message = [NSString stringWithFormat:@"verify: %@", (reason != nil ? reason : @"failed with an unknown reason")];
        [_failureHandler handleFailureWithReason:message];
    }
    
    if (matchingIndexes != nil) {
        [invocations removeObjectsAtIndexes:matchingIndexes];
    }
    
    return MCKContextModeRecording;
}


#pragma mark - Legacy

- (MCKContextMode)verifyInvocation:(NSInvocation *)invocation
                      withMatchers:(MCKArgumentMatcherCollection *)argMatchers
             inRecordedInvocations:(NSMutableArray *)recordedInvocations
{
    NSArray *matchers = argMatchers.primitiveArgumentMatchers;
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation argumentMatchers:matchers];
    return [self verifyPrototype:prototype invocations:recordedInvocations];
}

@end
