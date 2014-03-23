//
//  MCKArgumentMatcherCollectionTest.m
//  mocka
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKArgumentMatcherRecorder.h"
#import "MCKAnyArgumentMatcher.h"
#import "MCKMockingContext.h"
#import "MCKAPIMisuse.h"


@interface MCKArgumentMatcherRecorderTest : XCTestCase
@end

@implementation MCKArgumentMatcherRecorderTest {
    MCKArgumentMatcherRecorder *recorder;
    id<MCKArgumentMatcher> sampleMatcher;
}

#pragma mark - Setup

- (void)setUp {
    [MCKMockingContext currentContext]; // make sure a context exists
    recorder = [[MCKArgumentMatcherRecorder alloc] init];
    sampleMatcher = [[MCKAnyArgumentMatcher alloc] init];
}


#pragma mark - Test Managing Matchers

- (void)testThatAddPrimitiveMatcherAddsToEndOfMatchers {
    // when
    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
    
    // then
    expect(recorder.argumentMatchers).to.equal(@[ sampleMatcher ]);
}

- (void)testThatAddPrimitiveMatcherThrowsIfMoreMatchersAddedThanCanBeIndexedByUInt8 {
    // given
    for (int i = 0; i < (UINT8_MAX + 1); i++) { // UINT8_MAX + 1 => because 0 is an index as well
        [recorder addPrimitiveArgumentMatcher:sampleMatcher];
    }
    
    // then
    expect(^{ [recorder addPrimitiveArgumentMatcher:sampleMatcher]; }).to.raise(MCKAPIMisuseException);
}

- (void)testThatLastPrimitiveMatcherIndexReturnsIndexForLastAddedMatcher {
    XCTAssertEqual([recorder addPrimitiveArgumentMatcher:sampleMatcher], (UInt8)0, @"Wrong index returned");
    XCTAssertEqual([recorder addPrimitiveArgumentMatcher:sampleMatcher], (UInt8)1, @"Wrong index returned");
    XCTAssertEqual([recorder addPrimitiveArgumentMatcher:sampleMatcher], (UInt8)2, @"Wrong index returned");
}

- (void)testThatCollectingArgumentMatchersReturnsAllMatchers {
    // given
    NSArray *matchers = @[ [[MCKAnyArgumentMatcher alloc] init], [[MCKAnyArgumentMatcher alloc] init] ];
    [recorder addPrimitiveArgumentMatcher:matchers[0]];
    [recorder addPrimitiveArgumentMatcher:matchers[1]];
    
    // then
    XCTAssertEqualObjects([recorder collectAndReset], matchers, @"Matchers were not returned");
}

- (void)testThatCollectingArgumentMatchersRemovesAllMatchers {
    // given
    [recorder addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    
    // when
    [recorder collectAndReset];
    
    // then
    XCTAssertEqual([recorder.argumentMatchers count], (NSUInteger)0, @"Primitive matchers were not reset");
}


//#pragma mark - Test Validation
//
//- (void)testThatCollectionIsValidIfAllPrimitiveArgumentsForSignatureHaveMatchers {
//    // given
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
//    
//    // when
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    
//    // then
//    XCTAssertTrue([recorder isValidForMethodSignature:signature reason:NULL],
//                  @"Collection was not valid if all primitive args have matchers");
//}
//
//- (void)testThatCollectionIsValidIfAllPrimitiveArgumentsForSignatureWithObjectArgsHaveMatchers {
//    // given
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:i@i@"]; // 2 primitive args, 2 object args
//    
//    // when
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    
//    // then
//    XCTAssertTrue([recorder isValidForMethodSignature:signature reason:NULL],
//                  @"Collection was not valid if all primitive args have matchers");
//}
//
//- (void)testThatCollectionIsNotValidIfNotAllPrimitiveArgumentsHaveMatchers {
//    // given
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
//    
//    // when
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    
//    // then
//    XCTAssertFalse([recorder isValidForMethodSignature:signature reason:NULL],
//                   @"Collection was valid for less matchers than primitive args");
//}
//
//- (void)testThatCollectionIsNotValidIfThereAreMoreMatchersThanPrimitiveArguments {
//    // given
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
//    
//    // when
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    [recorder addPrimitiveArgumentMatcher:sampleMatcher];
//    
//    // then
//    XCTAssertFalse([recorder isValidForMethodSignature:signature reason:NULL],
//                   @"Collection was valid for more matchers than primitive args");
//}
//
//- (void)testThatCollectionIsValidIfSignatureHasNoPrimitiveArgsAndNoMatchersAreRecorded {
//    // given
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:"]; // no primitive args
//    
//    // when
//    // no matchers
//    
//    // then
//    XCTAssertTrue([recorder isValidForMethodSignature:signature reason:NULL],
//                  @"Collection was not valid for no matchers and no primitive args");
//}
//
//- (void)testThatCollectionIsValidIfSignatureHasPrimitiveArgsAndNoMatchersAreRecorded {
//    // given
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
//    
//    // when
//    // no matchers
//    
//    // then
//    XCTAssertTrue([recorder isValidForMethodSignature:signature reason:NULL],
//                  @"Collection was not valid for no matchers and no primitive args");
//}

@end
