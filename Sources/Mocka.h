//
//  Mocka.h
//  mocka
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKKeywords.h"
#import "MCKMockingContext.h"

#import "MCKMockObject.h"
#import "MCKSpy.h"

#import "MCKVerificationHandler.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKNeverVerificationHandler.h"
#import "MCKExactlyVerificationHandler.h"
#import "MCKVerifyNoInteractions.h"

#import "MCKStubAction.h"
#import "MCKReturnStubAction.h"
#import "MCKPerformBlockStubAction.h"
#import "MCKThrowExceptionStubAction.h"

#import "MCKArgumentMatcher.h"
#import "MCKAnyArgumentMatcher.h"

#import "NSInvocation+MCKArgumentHandling.h"
