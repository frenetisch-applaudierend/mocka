//
//  RGMockArgumentMatcherCollectionTest.m
//  rgmock
//
//  Created by Markus Gasser on 14.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RGMockArgumentMatcherCollection.h"
#import "RGMockAnyArgumentMatcher.h"


@interface RGMockArgumentMatcherCollectionTest : SenTestCase
@end

@implementation RGMockArgumentMatcherCollectionTest {
    RGMockArgumentMatcherCollection *collection;
}

#pragma mark - Setup

- (void)setUp {
    collection = [[RGMockArgumentMatcherCollection alloc] init];
}


#pragma mark - Adding new Matchers

- (void)testThatAddPrimitiveMatcherAddsToEndOfMatchers {
    // given
    id<RGMockArgumentMatcher> matcher = [[RGMockAnyArgumentMatcher alloc] init];
    
    // when
    [collection addPrimitiveArgumentMatcher:matcher];
    
    // then
    STAssertEqualObjects(collection.nonObjectArgumentMatchers, (@[ matcher ]), @"Primitive matcher was not recoreded");
}



#pragma mark - Test Validation

- (void)testThatCollectionIsValidIfAllPrimitiveArgumentsForSignatureHaveMatchers {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    
    // then
    STAssertTrue([collection isValidForMethodSignature:signature], @"Collection was not valid if all primitive args have matchers");
}

- (void)testThatCollectionIsValidIfAllPrimitiveArgumentsForSignatureWithObjectArgsHaveMatchers {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:i@i@"]; // 2 primitive args, 2 object args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    
    // then
    STAssertTrue([collection isValidForMethodSignature:signature], @"Collection was not valid if all primitive args have matchers");
}

- (void)testThatCollectionIsNotValidIfNotAllPrimitiveArgumentsHaveMatchers {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    
    // then
    STAssertFalse([collection isValidForMethodSignature:signature], @"Collection was valid for less matchers than primitive args");
}

- (void)testThatCollectionIsNotValidIfThereAreMoreMatchersThanPrimitiveArguments {
    // given
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:ii"]; // 2 primitive args
    
    // when
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    [collection addPrimitiveArgumentMatcher:[[RGMockAnyArgumentMatcher alloc] init]];
    
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
