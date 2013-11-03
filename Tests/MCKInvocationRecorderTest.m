//
//  MCKInvocationRecorderTest.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#define EXP_SHORTHAND
#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

#import "MCKInvocationRecorder.h"
#import "BlockInvocationRecorderDelegate.h"
#import "NSInvocation+TestSupport.h"


@interface MCKInvocationRecorderTest : XCTestCase @end
@implementation MCKInvocationRecorderTest {
    MCKInvocationRecorder *recorder;
    BlockInvocationRecorderDelegate *recorderDelegate;
}

#pragma mark - Setup

- (void)setUp {
    recorderDelegate = [[BlockInvocationRecorderDelegate alloc] init];
    recorder = [[MCKInvocationRecorder alloc] init];
    recorder.delegate = recorderDelegate;
}


#pragma mark - Test Recording an Invocation

- (void)testRecordingInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [recorder recordInvocation:invocation1];
    [recorder recordInvocation:invocation2];
    
    // then
    expect(recorder.recordedInvocations).to.equal(@[ invocation1, invocation2 ]);
}

- (void)testRecordingInvocationNotifiesDelegate {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    NSMutableArray *recordedInvocations = [NSMutableArray array];
    recorderDelegate.onRecordInvocation = ^(NSInvocation *invocation) {
        [recordedInvocations addObject:invocation];
    };
    
    // when
    [recorder recordInvocation:invocation1];
    [recorder recordInvocation:invocation2];
    
    // then
    expect(recordedInvocations).to.equal(@[ invocation1, invocation2 ]);
}

@end
