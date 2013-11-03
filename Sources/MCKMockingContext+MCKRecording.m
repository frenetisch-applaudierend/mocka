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
    return [self.mutableRecordedInvocations copy];
}

- (void)recordInvocation:(NSInvocation *)invocation {
    [self.mutableRecordedInvocations addObject:invocation];
    [self.invocationStubber applyStubsForInvocation:invocation];
}

@end
