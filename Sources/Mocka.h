//
//  Mocka.h
//  mocka
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mocka/MCKMockingSyntax.h>

#import <Mocka/MCKVerificationResult.h>
#import <Mocka/MCKVerificationHandler.h>
#import <Mocka/MCKDefaultVerificationHandler.h>
#import <Mocka/MCKNeverVerificationHandler.h>
#import <Mocka/MCKExactlyVerificationHandler.h>
#import <Mocka/MCKVerifyNoInteractions.h>

#import <Mocka/MCKStubAction.h>
#import <Mocka/MCKReturnStubAction.h>
#import <Mocka/MCKPerformBlockStubAction.h>
#import <Mocka/MCKThrowExceptionStubAction.h>
#import <Mocka/MCKSetOutParameterStubAction.h>

#import <Mocka/MCKArgumentMatcher.h>
#import <Mocka/MCKAnyArgumentMatcher.h>
#import <Mocka/MCKExactArgumentMatcher.h>
#import <Mocka/MCKBlockArgumentMatcher.h>
#import <Mocka/MCKHamcrestArgumentMatcher.h>

#import <Mocka/MCKTypes.h>
#import <Mocka/NSInvocation+MCKArgumentHandling.h>
