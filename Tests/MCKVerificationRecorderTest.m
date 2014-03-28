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
    MCKVerificationRecorder *verification;
    MCKMockingContext *context;
}

#pragma mark - Setup

- (void)setUp
{
    context = [[MCKMockingContext alloc] initWithTestCase:self];
    verification = [[MCKVerificationRecorder alloc] initWithMockingContext:context location:nil];
    
    context.invocationVerifier = MKTMock([MCKInvocationVerifier class]);
}


#pragma mark - Test Verification

//- (void)testThatVerificationIsExecutedAfterConfigurationIsDone
//{
//    MCKVerificationBlock block = ^{};
//    id<MCKVerificationHandler> handler = [[MCKDefaultVerificationHandler alloc] init];
//    MCKLocation *location = [MCKLocation locationWithFileName:@"Foo.m" lineNumber:10];
//    
//    _mck_verificationRecorder(context, location)
//    .setVerificationBlock(block)
//    .setVerificationHandler(handler)
//    .setTimeout(@10.0);
//    
//    MKTArgumentCaptor *verificationCapturer = [[MKTArgumentCaptor alloc] init];
//    [MKTVerify(context.invocationVerifier) processVerification:[verificationCapturer capture]];
//    
//    MCKVerification *capturedVerification = [verificationCapturer value];
//    expect(capturedVerification.verificationBlock).to.equal(block);
//    expect(capturedVerification.verificationHandler).to.equal(handler);
//    expect(capturedVerification.timeout).to.equal(10.0);
//}

@end
