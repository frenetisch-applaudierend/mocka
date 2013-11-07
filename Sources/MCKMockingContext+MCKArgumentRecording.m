//
//  MCKMockingContext+MCKArgumentRecording.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext+MCKArgumentRecording.h"
#import "MCKMockingContext+MCKFailureHandling.h"

#import "MCKArgumentMatcherRecorder.h"


@implementation MCKMockingContext (MCKArgumentRecording)

- (UInt8)pushPrimitiveArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if (![self checkCanPushArgumentMatcher]) {
        return 0;
    }
    return [self.argumentMatcherRecorder addPrimitiveArgumentMatcher:matcher];
}

- (UInt8)pushObjectArgumentMatcher:(id<MCKArgumentMatcher>)matcher {
    if (![self checkCanPushArgumentMatcher]) {
        return 0;
    }
    return [self.argumentMatcherRecorder addObjectArgumentMatcher:matcher];
}

- (BOOL)checkCanPushArgumentMatcher {
    if (self.mode == MCKContextModeRecording) {
        [self failWithReason:@"Argument matchers can only be used with stubbing or verification"];
        return NO;
    } else {
        return YES;
    }
}

@end
