//
//  MCKArgumentMatcherCollectionTest.m
//  mocka
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKArgumentMatcherCollection.h"
#import "MCKAnyArgumentMatcher.h"


@interface MCKArgumentMatcherCollectionTest : SenTestCase
@end

@implementation MCKArgumentMatcherCollectionTest {
    MCKArgumentMatcherCollection *collection;
}

#pragma mark - Setup

- (void)setUp {
    collection = [[MCKArgumentMatcherCollection alloc] init];
}


#pragma mark - Test Managing Matchers

- (void)testThatAddPrimitiveMatcherAddsToEndOfMatchers {
    // given
    id<MCKArgumentMatcher> matcher = [[MCKAnyArgumentMatcher alloc] init];
    
    // when
    [collection addPrimitiveArgumentMatcher:matcher];
    
    // then
    STAssertEqualObjects(collection.primitiveArgumentMatchers, (@[ matcher ]), @"Primitive matcher was not recoreded");
}

- (void)testThatAddPrimitiveMatcherThrowsIfMoreMatchersAddedThanCanBeIndexedByUInt8 {
    // given
    for (int i = 0; i < (UINT8_MAX + 1); i++) { // UINT8_MAX + 1 => because 0 is an index as well
        [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    }

    // then
    STAssertThrows([collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]], @"Should throw after %d matchers", (UINT8_MAX + 1));
}

- (void)testThatLastPrimitiveMatcherIndexReturnsIndexForLastAddedMatcher {
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    STAssertEquals([collection lastPrimitiveArgumentMatcherIndex], (UInt8)0, @"Wrong index returned");
    
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    STAssertEquals([collection lastPrimitiveArgumentMatcherIndex], (UInt8)1, @"Wrong index returned");
    
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    STAssertEquals([collection lastPrimitiveArgumentMatcherIndex], (UInt8)2, @"Wrong index returned");
}

- (void)testThatResetArgumentMatchersRemovesAllMatchers {
    // given
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    
    // when
    [collection resetAllMatchers];
    
    // then
    STAssertEquals([collection.primitiveArgumentMatchers count], (NSUInteger)0, @"Primitive matchers were not reset");
}


#pragma mark - Test Validation

- (void)testThatCollectionIsValidIfAllPrimitiveArgumentsForSignatureHaveMatchers {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    
    // then
    STAssertTrue([collection isValidForMethodSignature:signature], @"Collection was not valid if all primitive args have matchers");
}

- (void)testThatCollectionIsValidIfAllPrimitiveArgumentsForSignatureWithObjectArgsHaveMatchers {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:i@i@"]; // 2 primitive args, 2 object args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    
    // then
    STAssertTrue([collection isValidForMethodSignature:signature], @"Collection was not valid if all primitive args have matchers");
}

- (void)testThatCollectionIsNotValidIfNotAllPrimitiveArgumentsHaveMatchers {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    
    // then
    STAssertFalse([collection isValidForMethodSignature:signature], @"Collection was valid for less matchers than primitive args");
}

- (void)testThatCollectionIsNotValidIfThereAreMoreMatchersThanPrimitiveArguments {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[MCKAnyArgumentMatcher alloc] init]];
    
    // then
    STAssertFalse([collection isValidForMethodSignature:signature], @"Collection was valid for more matchers than primitive args");
}

- (void)testThatCollectionIsValidIfSignatureHasNoPrimitiveArgsAndNoMatchersAreRecorded {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:"]; // no primitive args
    
    // when
    // no matchers
    
    // then
    STAssertTrue([collection isValidForMethodSignature:signature], @"Collection was not valid for no matchers and no primitive args");
}

- (void)testThatCollectionIsValidIfSignatureHasPrimitiveArgsAndNoMatchersAreRecorded {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
    
    // when
    // no matchers
    
    // then
    STAssertTrue([collection isValidForMethodSignature:signature], @"Collection was not valid for no matchers and no primitive args");
}

@end
