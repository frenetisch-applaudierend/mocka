//
//  MCKMockingContext+MCKFailureHandling.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext+MCKFailureHandling.h"

#import "MCKFailureHandler.h"


@implementation MCKMockingContext (MCKFailureHandling)

- (void)failWithReason:(NSString *)reason, ... {
    va_list ap;
    va_start(ap, reason);
    NSString *formattedReason = [[NSString alloc] initWithFormat:reason arguments:ap];
    [self.failureHandler handleFailureAtLocation:self.currentLocation withReason:formattedReason];
    va_end(ap);
}

@end
