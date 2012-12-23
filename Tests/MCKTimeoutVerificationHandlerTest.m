//
//  MCKTimeoutVerificationHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 23.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKTimeoutVerificationHandler.h"
#import "MCKArgumentMatcherCollection.h"
#import "MCKInvocationCollection.h"

#import "FakeVerificationHandler.h"
#import "NSInvocation+TestSupport.h"


@interface MCKTimeoutVerificationHandlerTest : SenTestCase
@end

@implementation MCKTimeoutVerificationHandlerTest {
    MCKTimeoutVerificationHandler *timeoutHandler;
}

#pragma mark - Test Cases

- (void)testThatTimeoutHandlerPassesCallToPreviousHandler {
    // given
    FakeVerificationHandler *previousHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.0 currentVerificationHandler:previousHandler];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
    
    // when
    [timeoutHandler indexesMatchingInvocation:invocation
                         withArgumentMatchers:matchers
                        inRecordedInvocations:recordedInvocations
                                    satisfied:NULL
                               failureMessage:NULL];
    
    // then
    STAssertEqualObjects(previousHandler.lastInvocationPrototype, invocation, @"Wrong invocation passed");
    STAssertEqualObjects(previousHandler.lastArgumentMatchers, matchers.primitiveArgumentMatchers, @"Wrong matchers passed");
    STAssertEqualObjects(previousHandler.lastRecordedInvocations, recordedInvocations.allInvocations, @"Wrong recorded invocations passed");
}

- (void)testThatTimeoutHandlerReturnsIndexesIfPreviousHandlerIsSatisfied {
    // given
    FakeVerificationHandler *previousHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
                                                                                isSatisfied:YES];
    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.0 currentVerificationHandler:previousHandler];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
    
    // when
    NSIndexSet *returnValue = [timeoutHandler indexesMatchingInvocation:invocation
                                                   withArgumentMatchers:matchers
                                                  inRecordedInvocations:recordedInvocations
                                                              satisfied:NULL
                                                         failureMessage:NULL];
    
    // then
    STAssertEqualObjects(returnValue, [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)], @"Wrong indexes returned");
}

- (void)testThatTimeoutHandlerIsSatisfiedIfPreviousHandlerIsSatisfied {
    // given
    FakeVerificationHandler *previousHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
                                                                                isSatisfied:YES];
    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.0 currentVerificationHandler:previousHandler];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
    
    // when
    BOOL satisfied = NO;
    [timeoutHandler indexesMatchingInvocation:invocation
                         withArgumentMatchers:matchers
                        inRecordedInvocations:recordedInvocations
                                    satisfied:&satisfied
                               failureMessage:NULL];
    
    // then
    STAssertTrue(satisfied, @"Should be satisfied");
}

- (void)testThatTimeoutHandlerRetriesUntilPreviousHandlerIsSatisfied {
    // given
    __block NSUInteger calls = 0;
    FakeVerificationHandler *previousHandler =
    [FakeVerificationHandler handlerWithImplementation:
     ^(NSInvocation *prototype, MCKArgumentMatcherCollection *matchers, MCKInvocationCollection *recordedInvocations, BOOL *satisfied, NSString **reason) {
         if (calls == 4) {
             if (satisfied != NULL) *satisfied = YES;
             return [NSIndexSet indexSetWithIndex:10];
         }
         calls++;
         if (satisfied != NULL) *satisfied = NO;
         return [NSIndexSet indexSet];
     }];
    
    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.5 currentVerificationHandler:previousHandler];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
    
    // when
    BOOL satisfied = NO;
    NSIndexSet *returnValue = [timeoutHandler indexesMatchingInvocation:invocation
                                                   withArgumentMatchers:matchers
                                                  inRecordedInvocations:recordedInvocations
                                                              satisfied:&satisfied
                                                         failureMessage:NULL];
    
    // then
    STAssertEqualObjects(returnValue, [NSIndexSet indexSetWithIndex:10], @"Wrong indexes returned");
    STAssertTrue(satisfied, @"Should be satisfied");
}

- (void)testThatTimeoutHandlerWillStopAfterTimeoutIsReached {
    // given
    NSTimeInterval timeout = 0.2;
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:(timeout + 0.1)]; // include a bit of margin
    
    FakeVerificationHandler *previousHandler =
    [FakeVerificationHandler handlerWithImplementation:
     ^(NSInvocation *prototype, MCKArgumentMatcherCollection *matchers, MCKInvocationCollection *recordedInvocations, BOOL *satisfied, NSString **reason) {
         if ([[NSDate date] compare:(id)lastDate] == NSOrderedDescending) {
             STFail(@"Timeout not accepted");
             @throw [NSException exceptionWithName:@"StopTheTestException" reason:@"Stopping the test forcibly" userInfo:nil];
         }
         if (satisfied != NULL) *satisfied = NO;
         return [NSIndexSet indexSet];
     }];
    
    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:timeout currentVerificationHandler:previousHandler];
    
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
    
    // when
    BOOL satisfied = YES;
    NSIndexSet *returnValue = [timeoutHandler indexesMatchingInvocation:invocation
                                                   withArgumentMatchers:matchers
                                                  inRecordedInvocations:recordedInvocations
                                                              satisfied:&satisfied
                                                         failureMessage:NULL];
    
    // then
    STAssertEqualObjects(returnValue, [NSIndexSet indexSet], @"Wrong indexes returned");
    STAssertFalse(satisfied, @"Should not be satisfied");
}

@end
