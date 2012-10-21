//
//  ExamplesVerify.m
//  mocka
//
//  Created by Markus Gasser on 18.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ExamplesCommon.h"


@interface ExamplesVerify : SenTestCase
@end

@implementation ExamplesVerify {
    NSMutableArray *mockArray;
}

#pragma mark - Setup

- (void)setUp {
    SetupExampleErrorHandler();
    
    // we'll use this object in the examples
    mockArray = mock([NSMutableArray class]);
}


#pragma mark - Basic Verification

- (void)testVerifySimpleMethodCall {
    // you first use the mock  then verify that the desired method was called
    
    [mockArray removeAllObjects];
    
    verify [mockArray removeAllObjects];
}

- (void)testVerifyWillFailIfMethodWasNeverCalled {
    // if you verify a method that has never been called it will fail
    
    ThisWillFail({
        verify [mockArray removeAllObjects];
    });
}

- (void)testTooManyInvocationsAreIgnoredByVerify {
    // by default, verify will just check if a given method was at least called once
    // any more invocations are simply ignored
    
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    verify [mockArray removeAllObjects]; // too many invocations are ok
}

- (void)testYouCanUseMultipleVerifyTestsToRequireMultipleCalls {
    // if you wan to test that a method was called multiple times just repeat the verify call
    // (you can also use a modifier to verify, see below)
    
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    verify [mockArray removeAllObjects];
    verify [mockArray removeAllObjects]; // verify that the method was called at least 2 times
}

- (void)testVerifyingSomethingMultpleTimesThatWasCalledOnceWillFail {
    // from the example above follows that if you try to verify a call that was made only once
    // multiple times, the second verify will fail
    
    [mockArray removeAllObjects];
    
    verify [mockArray removeAllObjects];
    
    ThisWillFail({
        verify [mockArray removeAllObjects]; // multiple verify calls will also expect multiple invocations
    });
}


#pragma mark - Verification With Arguments

- (void)testVerifyWillMatchOnEqualArguments {
    // when you verify a method that has arguments verify will match equal arguments (isEqual: is used to compare)
    
    [mockArray addObject:@"Hello World"];
    
    verify [mockArray addObject:@"Hello World"];
}

- (void)testVerifyWillFailForUnequalArguments {
    // in contrast to above, if the arguments are not equal verify will not consider it a match
    
    [mockArray addObject:@"Hello World"];
    
    ThisWillFail({
        verify [mockArray addObject:@"Goodbye"];
    });
}

- (void)testYouCanUseArgumentMatchersInVerify {
    // instead of specifiying an exact value in verify you can also use argument matchers
    
    [mockArray addObject:@"Hello World"];
    
    verify [mockArray addObject:anyObject()];
}

- (void)testYouCanUseArgumentMatchersAlsoForPrimitiveArguments {
    // matchers are also available for primitive arguments
    
    [mockArray objectAtIndex:10];
    
    verify [mockArray objectAtIndex:anyInt()];
}

- (void)testYouCanMixArgumentsAndMatchersForObjects {
    // for object arguments you can just mix normal arguments and matchers
    
    [mockArray insertObjects:@[ @"foo" ] atIndexes:[NSIndexSet indexSetWithIndex:3]];
    
    verify [mockArray insertObjects:@[ @"foo" ] atIndexes:anyObject()];
}

- (void)testYouCanNotMixArgumentsAndMatchersForPrimitives {
    // for primitive arguments you must either use argument matchers only or no matchers at all
    
    [mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20];
    [mockArray exchangeObjectAtIndex:30 withObjectAtIndex:40];
    [mockArray exchangeObjectAtIndex:50 withObjectAtIndex:60];
    
    verify [mockArray exchangeObjectAtIndex:10 withObjectAtIndex:20];             // ok
    verify [mockArray exchangeObjectAtIndex:anyInt() withObjectAtIndex:anyInt()]; // ok
    ThisWillFail({
        verify [mockArray exchangeObjectAtIndex:50 withObjectAtIndex:anyInt()];   // not ok
    });
}


#pragma mark - Verify An Exact Number Of Invocations

- (void)testUseOnceToSpecifyExactlyOneInvocation {
    // by default verify will succeed if one *or more* calls which match are made
    // verify once will only succeed if there was *exactly* one call whitch matches
    // same as verify exactly(1)
    
    [mockArray count];
    [mockArray objectAtIndex:0];
    [mockArray objectAtIndex:1];
    
    verify once [mockArray count];
    ThisWillFail({
        verify once [mockArray objectAtIndex:anyInt()];
    });
}

- (void)testUseExactlyToSpecifyAnExactNumberOfInvocations {
    // using verify exactly(X) you can test that exactly X matching calls were made
    
    [mockArray objectAtIndex:0];
    [mockArray objectAtIndex:1];
    [mockArray count];
    
    verify exactly(2) [mockArray objectAtIndex:anyInt()];
    ThisWillFail({
        verify exactly(2) [mockArray count];
    });
}

- (void)testUseNeverToSpecifyNoMatchingCallsWereMade {
    // using verify never you can test that no matching call was made
    // same as verify exactly(0)
    
    [mockArray objectAtIndex:0];
    
    verify never [mockArray count];
    ThisWillFail({
        verify never [mockArray objectAtIndex:anyInt()];
    });
}


#pragma mark - Verify That No Actions Were Executed

- (void)testVerifyingNoInteractionsFailsIfAnyUnverifiedCallsWereMade {
    // using verify noInteractionsOn() or verify noMoreInteractionsOn() you can
    // check if no unverified invocations were done on the specified mock
    
    verify noInteractionsOn(mockArray); // no interactions made, all is fine
    
    [mockArray count];
    ThisWillFail({
        verify noInteractionsOn(mockArray); // [mockArray count] is an unverified interaction
    });
}

- (void)testVerifyingNoInteractionsDoesNotFailForVerifiedInteractions {
    // verified interactions are not checked with noInteractionsOn() / noMoreInteractionsOn()
    // note: the two variants are synonyms, but noMoreInteractionsOn() reads better when
    //       previous verify calls were made
    
    [mockArray count];
    
    verify [mockArray count];
    verify noMoreInteractionsOn(mockArray); // [mockArray count] was verified
}

@end
