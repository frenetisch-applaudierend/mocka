//
//  MCKVerificationTest.m
//  mocka
//
//  Created by Markus Gasser on 25.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>

#import "MCKVerificationRecorder.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKInvocationVerifier.h"
#import "MCKLocation.h"
#import "MCKVerification.h"
#import "MCKAPIMisuse.h"


@interface MCKVerificationRecorderTest : XCTestCase @end
@implementation MCKVerificationRecorderTest {
    MCKVerificationRecorder *recorder;
    MCKMockingContext *context;
}

#pragma mark - Setup

- (void)setUp
{
    context = [[MCKMockingContext alloc] initWithTestCase:self];
    context.invocationVerifier = MKTMock([MCKInvocationVerifier class]);
    
    recorder = [[MCKVerificationRecorder alloc] initWithMockingContext:context];
}


#pragma mark - Test Verification

- (void)testSettingPropertyRecordsInvocation {
    MCKVerification *verification = MKTMock([MCKVerification class]);
    
    recorder.recordVerification = verification;
    
    [MKTVerify(context.invocationVerifier) processVerification:verification];
}

@end
