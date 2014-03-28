//
//  MCKVerificationGroupTest.m
//  mocka
//
//  Created by Markus Gasser on 28.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKVerificationGroup.h"
#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"
#import "MCKVerificationResultCollector.h"
#import "MCKVerificationResult.h"


@interface MCKVerificationGroupTest : XCTestCase @end
@implementation MCKVerificationGroupTest {
    MCKVerificationGroup *verificationGroup;
    MCKMockingContext *context;
    id<MCKVerificationResultCollector> resultCollector;
}

#pragma mark - Setup

- (void)setUp
{
    context = [[MCKMockingContext alloc] init];
    context.invocationVerifier = MKTMock([MCKInvocationVerifier class]);
    
    resultCollector = MKTMockProtocol(@protocol(MCKVerificationResultCollector));
    verificationGroup = [[MCKVerificationGroup alloc] initWithMockingContext:context
                                                                    location:nil
                                                                   collector:resultCollector
                                                      verificationGroupBlock:nil];
}


#pragma mark - Test Execution

- (void)testThatExecuteCallsVerificationBlock
{
    __block BOOL wasCalled = NO;
    MCKVerificationGroup *group = [[MCKVerificationGroup alloc] initWithMockingContext:context
                                                                              location:nil
                                                                             collector:resultCollector
                                                                verificationGroupBlock:^{
                                                                    wasCalled = YES;
                                                                }];
    
    [group execute];
    
    expect(wasCalled).to.beTruthy();
}

- (void)testThatExecuteSetsContextModeToVerifiyingDuringCall
{
    __block MCKContextMode contextMode;
    MCKVerificationGroup *group = [[MCKVerificationGroup alloc] initWithMockingContext:context
                                                                              location:nil
                                                                             collector:resultCollector
                                                                verificationGroupBlock:^{
                                                                    contextMode = [context mode];
                                                                }];
    [context updateContextMode:MCKContextModeRecording];
    
    [group execute];
    
    expect(contextMode).to.equal(MCKContextModeVerifying);
}

- (void)testThatExecuteSetsContextModeToRecordingAfterCall
{
    [context updateContextMode:MCKContextModeVerifying];
    
    [verificationGroup execute];
    
    expect(context.mode).to.equal(MCKContextModeRecording);
}

@end
