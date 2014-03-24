//
//  MCKInvocationRecorderTest.m
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "TestingSupport.h"
#import "MCKInvocationRecorder.h"


@interface MCKInvocationRecorderTest : XCTestCase @end
@implementation MCKInvocationRecorderTest {
    MCKInvocationRecorder *invocationRecorder;
    FakeInvocationStubber *invocationStubber;
    FakeMockingContext *mockingContext;
}

#pragma mark - Setup

- (void)setUp {
    mockingContext = [FakeMockingContext fakeContext];
    
    invocationStubber = [FakeInvocationStubber fakeStubber];
    invocationRecorder = [[MCKInvocationRecorder alloc] initWithMockingContext:mockingContext];
    
    mockingContext.invocationRecorder = invocationRecorder;
    mockingContext.invocationStubber = invocationStubber;
}


#pragma mark - Test Getting Invocations

- (void)testInvocationAtIndexReturnsInvocation {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    [invocationRecorder appendInvocation:invocation1];
    [invocationRecorder appendInvocation:invocation2];
    
    // then
    expect([invocationRecorder invocationAtIndex:0]).to.equal(invocation1);
    expect([invocationRecorder invocationAtIndex:1]).to.equal(invocation2);
}

#pragma mark - Test Recording Invocations

- (void)testRecordingInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [invocationRecorder recordInvocationFromPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocation1]];
    [invocationRecorder recordInvocationFromPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocation2]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(@[ invocation1, invocation2 ]);
}

- (void)testRecordingInvocationAppliesStubs {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    NSMutableArray *appliedInvocations = [NSMutableArray array];
    [invocationStubber onApplyStubsForInvocation:^BOOL(NSInvocation *invocation) {
        [appliedInvocations addObject:invocation];
        return NO;
    }];
    
    // when
    [invocationRecorder recordInvocationFromPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocation1]];
    [invocationRecorder recordInvocationFromPrototype:[[MCKInvocationPrototype alloc] initWithInvocation:invocation2]];
    
    // then
    expect(appliedInvocations).to.equal(@[ invocation1, invocation2 ]);
}


#pragma mark - Test Adding Invocations

- (void)testAppendingInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [invocationRecorder appendInvocation:invocation1];
    [invocationRecorder appendInvocation:invocation2];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(@[ invocation1, invocation2 ]);
}

- (void)testInsertingInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation4 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSArray *inserted = @[ invocation3, invocation4 ];
    
    // when
    [invocationRecorder appendInvocation:invocation1];
    [invocationRecorder appendInvocation:invocation2];
    [invocationRecorder insertInvocations:inserted atIndex:0];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(@[ invocation3, invocation4, invocation1, invocation2 ]);
}


#pragma mark - Test Removing Invocations

- (void)testThatRemoveInvocationAtIndexesRemovesInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation4 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    [invocationRecorder appendInvocation:invocation1];
    [invocationRecorder appendInvocation:invocation2];
    [invocationRecorder appendInvocation:invocation3];
    [invocationRecorder appendInvocation:invocation4];
    
    // when
    [invocationRecorder removeInvocationsAtIndexes:[NSIndexSet indexSetWithIndex:1]];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(@[ invocation1, invocation3, invocation4 ]);
}

- (void)testThatRemoveInvocationInRangeRemovesInvocations {
    // given
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation4 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    [invocationRecorder appendInvocation:invocation1];
    [invocationRecorder appendInvocation:invocation2];
    [invocationRecorder appendInvocation:invocation3];
    [invocationRecorder appendInvocation:invocation4];
    
    // when
    [invocationRecorder removeInvocationsInRange:NSMakeRange(1, 2)];
    
    // then
    expect(invocationRecorder.recordedInvocations).to.equal(@[ invocation1, invocation4 ]);
}

@end
