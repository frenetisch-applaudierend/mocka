//
//  MCKMockingContext+MCKFailureHandling.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKMockingContext.h"


@interface MCKMockingContext (MCKFailureHandling)

- (void)failWithReason:(NSString *)reason, ... NS_FORMAT_FUNCTION(1,2);

@end
