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


#pragma mark - Verification with Arguments

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

@end
