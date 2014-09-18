//
//  MCKAPIMisuse.m
//  mocka
//
//  Created by Markus Gasser on 23.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "MCKAPIMisuse.h"


NSString * const MCKAPIMisuseException = @"MCKAPIMisuseException";

void MCKAPIMisuse(NSString *reason, ...) {
    va_list ap;
    va_start(ap, reason);
    NSString *fullReason = [[NSString alloc] initWithFormat:reason arguments:ap];
    va_end(ap);
    
    @throw [NSException exceptionWithName:MCKAPIMisuseException reason:fullReason userInfo:nil];
}
