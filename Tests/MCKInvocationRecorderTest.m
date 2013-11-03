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


#pragma mark - Test Getting Invocations

- (void)testInvocationAtIndexReturnsInvocation {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    [recorder appendInvocation:invocation1];
    [recorder appendInvocation:invocation2];
    
    // then
    expect([recorder invocationAtIndex:0]).to.equal(invocation1);
    expect([recorder invocationAtIndex:1]).to.equal(invocation2);
}


#pragma mark - Test Adding Invocations

- (void)testAppendingInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [recorder appendInvocation:invocation1];
    [recorder appendInvocation:invocation2];
    
    // then
    expect(recorder.recordedInvocations).to.equal(@[ invocation1, invocation2 ]);
}

- (void)testAppendingInvocationNotifiesDelegate {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    NSMutableArray *recordedInvocations = [NSMutableArray array];
    recorderDelegate.onRecordInvocation = ^(NSInvocation *invocation) {
        [recordedInvocations addObject:invocation];
    };
    
    // when
    [recorder appendInvocation:invocation1];
    [recorder appendInvocation:invocation2];
    
    // then
    expect(recordedInvocations).to.equal(@[ invocation1, invocation2 ]);
}

- (void)testInsertingInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation4 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSArray *inserted = @[ invocation3, invocation4 ];
    
    // when
    [recorder appendInvocation:invocation1];
    [recorder appendInvocation:invocation2];
    [recorder insertInvocations:inserted atIndex:0];
    
    // then
    expect(recorder.recordedInvocations).to.equal(@[ invocation3, invocation4, invocation1, invocation2 ]);
}


#pragma mark - Test Removing Invocations

- (void)testThatRemoveInvocationAtIndexesRemovesInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation4 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    [recorder appendInvocation:invocation1];
    [recorder appendInvocation:invocation2];
    [recorder appendInvocation:invocation3];
    [recorder appendInvocation:invocation4];
    
    // when
    [recorder removeInvocationsAtIndexes:[NSIndexSet indexSetWithIndex:1]];
    
    // then
    expect(recorder.recordedInvocations).to.equal(@[ invocation1, invocation3, invocation4 ]);
}

- (void)testThatRemoveInvocationInRangeRemovesInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation4 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    [recorder appendInvocation:invocation1];
    [recorder appendInvocation:invocation2];
    [recorder appendInvocation:invocation3];
    [recorder appendInvocation:invocation4];
    
    // when
    [recorder removeInvocationsInRange:NSMakeRange(1, 2)];
    
    // then
    expect(recorder.recordedInvocations).to.equal(@[ invocation1, invocation4 ]);
}

@end
