//
//  MCKInvocationCollectionTest.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKInvocationCollection.h"
#import "MCKArgumentMatcherCollection.h"

#import "NSInvocation+TestSupport.h"
#import "BlockInvocationMatcher.h"
#import "BlockArgumentMatcher.h"


@interface MCKInvocationCollectionTest : SenTestCase
@end

@implementation MCKInvocationCollectionTest {
    MCKMutableInvocationCollection *invocationCollection;
    BlockInvocationMatcher *invocationMatcher;
}

#pragma mark - Setup

- (void)setUp {
    invocationMatcher = [[BlockInvocationMatcher alloc] init];
    invocationCollection = [[MCKMutableInvocationCollection alloc] initWithInvocationMatcher:invocationMatcher];
}


#pragma mark - Test Recording Invocations

- (void)testThatRecordInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation0 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [invocationCollection addInvocation:invocation0];
    [invocationCollection addInvocation:invocation1];
    
    // then
    STAssertEqualObjects(invocationCollection.allInvocations, (@[ invocation0, invocation1 ]), @"Invocations were not recorded as required");
}

- (void)testThatRecordInvocationMakesInvocationRetainArguments {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [invocationCollection addInvocation:invocation];
    
    // then
    STAssertTrue([invocation argumentsRetained], @"Arguments should be retained by the invocation");
}


#pragma mark - Querying for Invocations

- (void)testThatInvocationsMatchingPrototypePassesEachRecordedInvocationToMatcherInOrder {
    // given
    NSInvocation *invocation0 = [NSInvocation voidMethodInvocationForTarget:nil]; [invocationCollection addInvocation:invocation0];
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil]; [invocationCollection addInvocation:invocation1];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil]; [invocationCollection addInvocation:invocation2];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil]; [invocationCollection addInvocation:invocation3];
    
    NSMutableArray *testedInvocations = [NSMutableArray array];
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        [testedInvocations addObject:candidate];
        return YES;
    }];
    
    // when
    [invocationCollection invocationsMatchingPrototype:[NSInvocation voidMethodInvocationForTarget:nil] withArgumentMatchers:nil];
    
    // then
    STAssertEqualObjects(testedInvocations, (@[ invocation0, invocation1, invocation2, invocation3 ]),
                         @"Invocations not all tested or not in correct order");
}

- (void)testThatInvocationsMatchingPrototypePassesArgumentMatchersToMatcher {
    // given
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    
    NSArray *primitiveArgMatchers = @[ [[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init] ];
    NSMutableArray *passedMatchers = [NSMutableArray array];
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        [passedMatchers addObject:argMatchers];
        return YES;
    }];
    
    // when
    [invocationCollection invocationsMatchingPrototype:[NSInvocation voidMethodInvocationForTarget:nil]
                      withArgumentMatchers:[[MCKArgumentMatcherCollection alloc] initWithPrimitiveArgumentMatchers:primitiveArgMatchers]];
    
    // then
    for (NSArray *matchers in passedMatchers) {
        STAssertEqualObjects(matchers, primitiveArgMatchers, @"Wrong matchers passed");
    }
}

- (void)testThatInvocationsMatchingPrototypeReturnsIndexesForMatchingInvocationsInOrder {
    // given
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:@"Match"]];
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:@"No Match"]];
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:@"No Match"]];
    [invocationCollection addInvocation:[NSInvocation voidMethodInvocationForTarget:@"Match"]];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return [candidate.target isEqual:@"Match"];
    }];
    
    // when
    NSIndexSet *matchingIndexes = [invocationCollection invocationsMatchingPrototype:[NSInvocation voidMethodInvocationForTarget:nil]
                                                                withArgumentMatchers:nil];
    
    // then
    NSMutableIndexSet *expectedIndexes = [NSMutableIndexSet indexSet];
    [expectedIndexes addIndex:0];
    [expectedIndexes addIndex:3];
    STAssertEqualObjects(matchingIndexes, expectedIndexes, @"Incorrect matches");
}


#pragma mark - Test Removing Matchers

- (void)testThatRemoveMatchersAtIndexesRemovesMatchers {
    // given
    NSInvocation *invocation0 = [NSInvocation voidMethodInvocationForTarget:self]; [invocationCollection addInvocation:invocation0];
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:self]; [invocationCollection addInvocation:invocation1];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:self]; [invocationCollection addInvocation:invocation2];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:self]; [invocationCollection addInvocation:invocation3];
    
    // when
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    [indexes addIndex:1];
    [indexes addIndex:3];
    [invocationCollection removeInvocationsAtIndexes:indexes];
    
    // then
    STAssertEqualObjects(invocationCollection.allInvocations, (@[ invocation0, invocation2 ]), @"Invocations were not recorded as required");
}


#pragma mark - Test Deriving New Matchers

- (void)testThatDerivingSubcollectionFromIndexSkipsFirstInvocations {
    // given
    NSArray *invocations = @[ [NSInvocation voidMethodInvocationForTarget:self],
                              [NSInvocation voidMethodInvocationForTarget:self],
                              [NSInvocation voidMethodInvocationForTarget:self] ];
    MCKInvocationCollection *source = [[MCKInvocationCollection alloc] initWithInvocationMatcher:nil invocations:invocations];
    
    // when
    MCKInvocationCollection *derived = [source subcollectionFromIndex:1];
    
    // then
    STAssertEqualObjects(derived.allInvocations, [invocations subarrayWithRange:NSMakeRange(1, 2)], @"Wrong invocations in subarray");
}

- (void)testThatDerivingSubcollectionFromIndexZeroReturnsAllInvocations {
    // given
    NSArray *invocations = @[ [NSInvocation voidMethodInvocationForTarget:self],
                              [NSInvocation voidMethodInvocationForTarget:self],
                              [NSInvocation voidMethodInvocationForTarget:self] ];
    MCKInvocationCollection *source = [[MCKInvocationCollection alloc] initWithInvocationMatcher:nil invocations:invocations];
    
    // when
    MCKInvocationCollection *derived = [source subcollectionFromIndex:0];
    
    // then
    STAssertEqualObjects(derived.allInvocations, source.allInvocations, @"Wrong invocations in subarray");
}

- (void)testThatDerivingSubcollectionFromIndexLastIndexPlusOneReturnsNoInvocations {
    // given
    NSArray *invocations = @[ [NSInvocation voidMethodInvocationForTarget:self],
                              [NSInvocation voidMethodInvocationForTarget:self],
                              [NSInvocation voidMethodInvocationForTarget:self] ];
    MCKInvocationCollection *source = [[MCKInvocationCollection alloc] initWithInvocationMatcher:nil invocations:invocations];
    
    // when
    MCKInvocationCollection *derived = [source subcollectionFromIndex:[invocations count]];
    
    // then
    STAssertEqualObjects(derived.allInvocations, @[], @"Wrong invocations in subarray");
}

@end
