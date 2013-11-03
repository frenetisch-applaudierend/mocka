//
//  MCKMockingContext+MCKRecording.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext+MCKRecording.h"
#import "MCKInvocationStubber.h"


@implementation MCKMockingContext (MCKRecording)

- (NSArray *)recordedInvocations {
    return self.invocationRecorder.recordedInvocations;
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [self.invocationRecorder appendInvocation:invocation];
}

- (void)invocationRecorder:(MCKInvocationRecorder *)recorded didRecordInvocation:(NSInvocation *)invocation {
    [self.invocationStubber applyStubsForInvocation:invocation];
}

@end
