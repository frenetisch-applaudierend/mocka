//
//  MCKVerificationGroupRecorderTest.m
//  mocka
//
//  Created by Markus Gasser on 29.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKVerificationGroupRecorder.h"
#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"
#import "MCKVerificationResultCollector.h"


@interface MCKVerificationGroupRecorderTest : XCTestCase @end
@implementation MCKVerificationGroupRecorderTest

- (void)testThatSettingTheBlockProcessesGroup
{
    MCKMockingContext *context = [[MCKMockingContext alloc] init];
    context.invocationVerifier = MKTMock([MCKInvocationVerifier class]);
    
    MCKLocation *location = [MCKLocation locationWithFileName:@"Foo.m" lineNumber:10];
    id<MCKVerificationResultCollector> collector = MKTMockProtocol(@protocol(MCKVerificationResultCollector));
    MCKVerificationGroupBlock block = ^{};
    
    MCKVerificationGroupRecorder *recorder = [[MCKVerificationGroupRecorder alloc] initWithMockingContext:context
                                                                                                 location:location
                                                                                          resultCollector:collector];
    
    recorder.recordGroupWithBlock = block;
    
    MKTArgumentCaptor *argumentCaptor = [[MKTArgumentCaptor alloc] init];
    [MKTVerify(context.invocationVerifier) processVerificationGroup:[argumentCaptor capture]];
    
    MCKVerificationGroup *group = [argumentCaptor value];
    expect(group.mockingContext).to.equal(context);
    expect(group.location).to.equal(location);
    expect(group.resultCollector).to.equal(collector);
    expect(group.verificationGroupBlock).to.equal(block);
}

@end
