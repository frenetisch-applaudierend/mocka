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
    context.invocationRecorder = MKTMock([MCKInvocationRecorder class]);
    
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
    
    [group executeWithInvocationRecorder:nil];
    
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
    
    [group executeWithInvocationRecorder:nil];
    
    expect(contextMode).to.equal(MCKContextModeVerifying);
}

- (void)testThatExecuteSetsContextModeToRecordingAfterCall
{
    [context updateContextMode:MCKContextModeVerifying];
    
    [verificationGroup executeWithInvocationRecorder:nil];
    
    expect(context.mode).to.equal(MCKContextModeRecording);
}


#pragma mark - Test Delegating to the Result Collector

- (void)testThatExecuteWillBeginCollector
{
    [verificationGroup executeWithInvocationRecorder:context.invocationRecorder];
    
    [MKTVerify(resultCollector) beginCollectingResultsWithInvocationRecorder:context.invocationRecorder];
}

- (void)testThatCollectResultReturnsResultFromCollector
{
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:10]];
    [MKTGiven([resultCollector collectVerificationResult:HC_anything()]) willReturn:result];
    
    expect([verificationGroup collectResult:[MCKVerificationResult successWithMatchingIndexes:nil]]).to.equal(result);
}

- (void)testThatExecuteReturnsResultFromCollector
{
    MCKVerificationResult *result = [MCKVerificationResult successWithMatchingIndexes:[NSIndexSet indexSetWithIndex:10]];
    [MKTGiven([resultCollector finishCollectingResults]) willReturn:result];
    
    expect([verificationGroup executeWithInvocationRecorder:nil]).to.equal(result);
}

@end
