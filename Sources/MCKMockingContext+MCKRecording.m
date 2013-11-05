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

- (void)invocationRecorder:(MCKInvocationRecorder *)recorded didRecordInvocation:(NSInvocation *)invocation {
    [self.invocationStubber applyStubsForInvocation:invocation];
}

@end
