//
//  MCKTimeoutVerificationHandlerTest.m
//  mocka
//
//  Created by Markus Gasser on 23.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKTimeoutVerificationHandler.h"
#import "MCKNeverVerificationHandler.h"

#import "FakeVerificationHandler.h"
#import "NSInvocation+TestSupport.h"


@interface MCKTimeoutVerificationHandlerTest : XCTestCase
@end

@implementation MCKTimeoutVerificationHandlerTest {
    MCKTimeoutVerificationHandler *timeoutHandler;
}

#pragma mark - Test Cases

//- (void)testThatTimeoutHandlerPassesCallToPreviousHandler {
//    // given
//    FakeVerificationHandler *previousHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSet] isSatisfied:YES];
//    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.0 currentVerificationHandler:previousHandler];
//    
//    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
//    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
//    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
//    
//    // when
//    [timeoutHandler indexesMatchingInvocation:invocation
//                         withArgumentMatchers:matchers
//                        inRecordedInvocations:recordedInvocations
//                                    satisfied:NULL
//                               failureMessage:NULL];
//    
//    // then
//    XCTAssertEqualObjects(previousHandler.lastInvocationPrototype, invocation, @"Wrong invocation passed");
//    XCTAssertEqualObjects(previousHandler.lastArgumentMatchers, matchers.primitiveArgumentMatchers, @"Wrong matchers passed");
//    XCTAssertEqualObjects(previousHandler.lastRecordedInvocations, recordedInvocations.allInvocations, @"Wrong recorded invocations passed");
//}

//- (void)testThatTimeoutHandlerReturnsIndexesIfPreviousHandlerIsSatisfied {
//    // given
//    FakeVerificationHandler *previousHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
//                                                                                isSatisfied:YES];
//    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.0 currentVerificationHandler:previousHandler];
//    
//    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
//    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
//    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
//    
//    // when
//    NSIndexSet *returnValue = [timeoutHandler indexesMatchingInvocation:invocation
//                                                   withArgumentMatchers:matchers
//                                                  inRecordedInvocations:recordedInvocations
//                                                              satisfied:NULL
//                                                         failureMessage:NULL];
//    
//    // then
//    XCTAssertEqualObjects(returnValue, [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)], @"Wrong indexes returned");
//}

//- (void)testThatTimeoutHandlerIsSatisfiedIfPreviousHandlerIsSatisfied {
//    // given
//    FakeVerificationHandler *previousHandler = [FakeVerificationHandler handlerWhichReturns:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
//                                                                                isSatisfied:YES];
//    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.0 currentVerificationHandler:previousHandler];
//    
//    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
//    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
//    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
//    
//    // when
//    BOOL satisfied = NO;
//    [timeoutHandler indexesMatchingInvocation:invocation
//                         withArgumentMatchers:matchers
//                        inRecordedInvocations:recordedInvocations
//                                    satisfied:&satisfied
//                               failureMessage:NULL];
//    
//    // then
//    XCTAssertTrue(satisfied, @"Should be satisfied");
//}

//- (void)testThatTimeoutHandlerRetriesUntilPreviousHandlerIsSatisfied {
//    // given
//    __block NSUInteger calls = 0;
//    FakeVerificationHandler *previousHandler =
//    [FakeVerificationHandler handlerWithImplementation:
//     ^(NSInvocation *prototype, MCKArgumentMatcherCollection *matchers, MCKInvocationCollection *recordedInvocations, BOOL *satisfied, NSString **reason) {
//         if (calls == 4) {
//             if (satisfied != NULL) *satisfied = YES;
//             return [NSIndexSet indexSetWithIndex:10];
//         }
//         calls++;
//         if (satisfied != NULL) *satisfied = NO;
//         return [NSIndexSet indexSet];
//     }];
//    
//    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.5 currentVerificationHandler:previousHandler];
//    
//    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
//    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
//    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
//    
//    // when
//    BOOL satisfied = NO;
//    NSIndexSet *returnValue = [timeoutHandler indexesMatchingInvocation:invocation
//                                                   withArgumentMatchers:matchers
//                                                  inRecordedInvocations:recordedInvocations
//                                                              satisfied:&satisfied
//                                                         failureMessage:NULL];
//    
//    // then
//    XCTAssertEqualObjects(returnValue, [NSIndexSet indexSetWithIndex:10], @"Wrong indexes returned");
//    XCTAssertTrue(satisfied, @"Should be satisfied");
//}

//- (void)testThatTimeoutHandlerWillStopAfterTimeoutIsReached {
//    // given
//    NSTimeInterval timeout = 0.2;
//    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:(timeout + 0.1)]; // include a bit of margin
//    
//    FakeVerificationHandler *previousHandler =
//    [FakeVerificationHandler handlerWithImplementation:
//     ^(NSInvocation *prototype, MCKArgumentMatcherCollection *matchers, MCKInvocationCollection *recordedInvocations, BOOL *satisfied, NSString **reason) {
//         if ([[NSDate date] compare:(id)lastDate] == NSOrderedDescending) {
//             XCTFail(@"Timeout not accepted");
//             @throw [NSException exceptionWithName:@"StopTheTestException" reason:@"Stopping the test forcibly" userInfo:nil];
//         }
//         if (satisfied != NULL) *satisfied = NO;
//         return [NSIndexSet indexSet];
//     }];
//    
//    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:timeout currentVerificationHandler:previousHandler];
//    
//    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
//    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
//    MCKInvocationCollection *recordedInvocations = [[MCKInvocationCollection alloc] init];
//    
//    // when
//    BOOL satisfied = YES;
//    NSIndexSet *returnValue = [timeoutHandler indexesMatchingInvocation:invocation
//                                                   withArgumentMatchers:matchers
//                                                  inRecordedInvocations:recordedInvocations
//                                                              satisfied:&satisfied
//                                                         failureMessage:NULL];
//    
//    // then
//    XCTAssertEqualObjects(returnValue, [NSIndexSet indexSet], @"Wrong indexes returned");
//    XCTAssertFalse(satisfied, @"Should not be satisfied");
//}


#pragma mark - Test Cases with "never" handler

//- (void)testThatNeverHandlerFailsIfCallIsMadeWhileTimeout {
//    // given
//    MCKNeverVerificationHandler *previousHandler = [MCKNeverVerificationHandler neverHandler];
//    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.2 currentVerificationHandler:previousHandler];
//    
//    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
//    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
//    MCKMutableInvocationCollection *recordedInvocations = [[MCKMutableInvocationCollection alloc] init];
//    
//    // when
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//        [recordedInvocations addInvocation:invocation];
//    });
//    
//    BOOL satisfied = YES;
//    [timeoutHandler indexesMatchingInvocation:invocation withArgumentMatchers:matchers inRecordedInvocations:recordedInvocations
//                                    satisfied:&satisfied failureMessage:NULL];
//    
//    // then
//    XCTAssertFalse(satisfied, @"Should not be satisfied");
//}

//- (void)testThatNeverHandlerSucceedsIfNoCallIsMadeWhileTimeout {
//    // given
//    MCKNeverVerificationHandler *previousHandler = [MCKNeverVerificationHandler neverHandler];
//    timeoutHandler = [MCKTimeoutVerificationHandler timeoutHandlerWithTimeout:0.1 currentVerificationHandler:previousHandler];
//    
//    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(description)];
//    MCKArgumentMatcherCollection *matchers = [[MCKArgumentMatcherCollection alloc] init];
//    MCKMutableInvocationCollection *recordedInvocations = [[MCKMutableInvocationCollection alloc] init];
//    
//    // when
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//        [recordedInvocations addInvocation:invocation];
//    });
//    
//    BOOL satisfied = NO;
//    [timeoutHandler indexesMatchingInvocation:invocation withArgumentMatchers:matchers inRecordedInvocations:recordedInvocations
//                                    satisfied:&satisfied failureMessage:NULL];
//    
//    // then
//    XCTAssertTrue(satisfied, @"Should be satisfied");
//}

@end
