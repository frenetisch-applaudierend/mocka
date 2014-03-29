//
//  Mocka.h
//  mocka
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKMockingSyntax.h"
#import "MCKStubbingSyntax.h"
#import "MCKVerificationSyntax.h"

#import "MCKInvocationRecorder.h"
#import "MCKVerification.h"
#import "MCKVerificationGroup.h"
#import "MCKVerificationResult.h"
#import "MCKStub.h"

#import "MCKVerificationResultCollector.h"
#import "MCKAnyOfCollector.h"
#import "MCKInOrderCollector.h"
#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKNeverVerificationHandler.h"
#import "MCKExactlyVerificationHandler.h"
#import "MCKVerifyNoInteractions.h"

#import "MCKArgumentMatcher.h"
#import "MCKAnyArgumentMatcher.h"
#import "MCKExactArgumentMatcher.h"
#import "MCKBlockArgumentMatcher.h"
#import "MCKHamcrestArgumentMatcher.h"

#import "MCKNetworkMock.h"
#import "MCKNetworkRequestMatcher.h"
