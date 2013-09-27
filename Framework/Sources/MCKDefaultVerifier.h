//
//  MCKDefaultVerifier.h
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerifier.h"


@interface MCKDefaultVerifier : NSObject <MCKVerifier>

- (MCKContextMode)verifyInvocation:(NSInvocation *)invocation
                      withMatchers:(MCKArgumentMatcherCollection *)argMatchers
             inRecordedInvocations:(NSMutableArray *)recordedInvocations;

@end
