//
//  MCKInvocationCollectionTest.m
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKInvocationCollection.h"

#import "NSInvocation+TestSupport.h"
#import "BlockInvocationMatcher.h"
#import "BlockArgumentMatcher.h"


@interface MCKInvocationCollectionTest : SenTestCase
@end

@implementation MCKInvocationCollectionTest {
    MCKMutableInvocationCollection *recorder;
    BlockInvocationMatcher   *invocationMatcher;
}

#pragma mark - Setup

- (void)setUp {
    invocationMatcher = [[BlockInvocationMatcher alloc] init];
    recorder = [[MCKMutableInvocationCollection alloc] initWithInvocationMatcher:invocationMatcher];
}


#pragma mark - Test Recording Invocations

- (void)testThatRecordInvocationAddsToRecordedInvocations {
    // given
    NSInvocation *invocation0 = [NSInvocation voidMethodInvocationForTarget:nil];
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [recorder addInvocation:invocation0];
    [recorder addInvocation:invocation1];
    
    // then
    STAssertEqualObjects(recorder.allInvocations, (@[ invocation0, invocation1 ]), @"Invocations were not recorded as required");
}

- (void)testThatRecordInvocationMakesInvocationRetainArguments {
    // given
    NSInvocation *invocation = [NSInvocation voidMethodInvocationForTarget:nil];
    
    // when
    [recorder addInvocation:invocation];
    
    // then
    STAssertTrue([invocation argumentsRetained], @"Arguments should be retained by the invocation");
}


#pragma mark - Querying for Invocations

- (void)testThatInvocationsMatchingPrototypePassesEachRecordedInvocationToMatcherInOrder {
    // given
    NSInvocation *invocation0 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation0];
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation1];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation2];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation3];
    
    NSMutableArray *testedInvocations = [NSMutableArray array];
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        [testedInvocations addObject:candidate];
        return YES;
    }];
    
    // when
    [recorder invocationsMatchingPrototype:[NSInvocation voidMethodInvocationForTarget:nil] withPrimitiveArgumentMatchers:nil];
    
    // then
    STAssertEqualObjects(testedInvocations, (@[ invocation0, invocation1, invocation2, invocation3 ]), @"Invocations not all tested or not in correct order");
}

- (void)testThatInvocationsMatchingPrototypePassesArgumentMatchersToMatcher {
    // given
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:nil]];
    
    NSArray *primitiveArgMatchers = @[ [[BlockArgumentMatcher alloc] init], [[BlockArgumentMatcher alloc] init] ];
    NSMutableArray *passedMatchers = [NSMutableArray array];
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        [passedMatchers addObject:argMatchers];
        return YES;
    }];
    
    // when
    [recorder invocationsMatchingPrototype:[NSInvocation voidMethodInvocationForTarget:nil] withPrimitiveArgumentMatchers:primitiveArgMatchers];
    
    // then
    for (NSArray *matchers in passedMatchers) {
        STAssertEqualObjects(matchers, primitiveArgMatchers, @"Wrong matchers passed");
    }
}

- (void)testThatInvocationsMatchingPrototypeReturnsIndexesForMatchingInvocationsInOrder {
    // given
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:@"Match"]];
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:@"No Match"]];
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:@"No Match"]];
    [recorder addInvocation:[NSInvocation voidMethodInvocationForTarget:@"Match"]];
    
    [invocationMatcher setMatcherImplementation:^BOOL(NSInvocation *candidate, NSInvocation *prototype, NSArray *argMatchers) {
        return [candidate.target isEqual:@"Match"];
    }];
    
    // when
    NSIndexSet *matchingIndexes = [recorder invocationsMatchingPrototype:[NSInvocation voidMethodInvocationForTarget:nil] withPrimitiveArgumentMatchers:nil];
    
    // then
    NSMutableIndexSet *expectedIndexes = [NSMutableIndexSet indexSet];
    [expectedIndexes addIndex:0];
    [expectedIndexes addIndex:3];
    STAssertEqualObjects(matchingIndexes, expectedIndexes, @"Incorrect matches");
}


#pragma mark - Test Removing Matchers

- (void)testThatRemoveMatchersAtIndexesRemovesMatchers {
    // given
    NSInvocation *invocation0 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation0];
    NSInvocation *invocation1 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation1];
    NSInvocation *invocation2 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation2];
    NSInvocation *invocation3 = [NSInvocation voidMethodInvocationForTarget:nil]; [recorder addInvocation:invocation3];
    
    // when
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    [indexes addIndex:1];
    [indexes addIndex:3];
    [recorder removeInvocationsAtIndexes:indexes];
    
    // then
    STAssertEqualObjects(recorder.allInvocations, (@[ invocation0, invocation2 ]), @"Invocations were not recorded as required");
}

@end
