//
//  MCKMockingContext+MCKRecording.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext.h"
#import "MCKInvocationRecorder.h"


@interface MCKMockingContext (MCKRecording) <MCKInvocationRecorderDelegate>

@property (nonatomic, readonly) NSArray *recordedInvocations;

- (void)recordInvocation:(NSInvocation *)invocation;

@end
