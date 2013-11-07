//
//  BlockInvocationVerifierDelegate.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "BlockInvocationVerifierDelegate.h"


@implementation BlockInvocationVerifierDelegate

- (void)invocationVerifier:(MCKInvocationVerifier *)verififer didFailWithReason:(NSString *)reason {
    if (self.onFailure != nil) {
        self.onFailure(reason);
    }
}

- (void)invocationVerifierDidEnd:(MCKInvocationVerifier *)verififer {
    if (self.onFinish != nil) {
        self.onFinish();
    }
}

- (void)invocationVerifierWillProcessTimeout:(MCKInvocationVerifier *)verififer {
    if (self.onWillProcessTimeout != nil) {
        self.onWillProcessTimeout();
    }
}

- (void)invocationVerifierDidProcessTimeout:(MCKInvocationVerifier *)verififer {
    if (self.onDidProcessTimeout != nil) {
        self.onDidProcessTimeout();
    }
}

@end
