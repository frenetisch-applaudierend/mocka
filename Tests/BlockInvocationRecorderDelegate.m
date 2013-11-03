//
//  BlockInvocationRecorderDelegate.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "BlockInvocationRecorderDelegate.h"


@implementation BlockInvocationRecorderDelegate

- (void)invocationRecorder:(MCKInvocationRecorder *)recorded didRecordInvocation:(NSInvocation *)invocation {
    if (self.onRecordInvocation != nil) {
        self.onRecordInvocation(invocation);
    }
}

@end
