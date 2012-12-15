//
//  MCKVerifier.h
//  mocka
//
//  Created by Markus Gasser on 15.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKMockingContext.h"


@protocol MCKVerificationHandler;
@class MCKMutableInvocationCollection;
@class MCKArgumentMatcherCollection;
@class MCKFailureHandler;


@protocol MCKVerifier <NSObject>

@property (nonatomic, strong) id<MCKVerificationHandler> verificationHandler;
@property (nonatomic, strong) MCKFailureHandler *failureHandler;

- (MCKContextMode)verifyInvocation:(NSInvocation *)invocation
                      withMatchers:(MCKArgumentMatcherCollection *)matchers
             inRecordedInvocations:(MCKMutableInvocationCollection *)recordedInvocations;

@end
