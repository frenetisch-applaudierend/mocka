//
//  MCKMockingContext+MCKStubbing.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext+MCKStubbing.h"

#import "MCKInvocationStubber.h"
#import "MCKArgumentMatcherRecorder.h"
#import "MCKInvocationPrototype.h"


@implementation MCKMockingContext (MCKStubbing)

- (void)beginStubbing {
    [self updateContextMode:MCKContextModeStubbing];
}

- (void)endStubbing {
    [self.invocationStubber finishRecordingStubGroup];
    [self updateContextMode:MCKContextModeRecording];
}

- (BOOL)isInvocationStubbed:(NSInvocation *)invocation {
    return [self.invocationStubber hasStubsRecordedForInvocation:invocation];
}

- (MCKStub *)activeStub {
    return [[self.invocationStubber recordedStubs] lastObject];
}

@end
