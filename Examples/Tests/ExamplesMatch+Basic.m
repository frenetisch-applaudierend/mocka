//
//  ExamplesMatch+Basic.m
//  Examples
//
//  Created by Markus Gasser on 10.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>


@interface ExamplesMatch_Basic : ExampleTestCase @end
@implementation ExamplesMatch_Basic {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Basic Matching

- (void)testMatchWillSucceedWhenItFindsCalls
{
    // you first use the mock  then check that the desired method was called using match (...)
    
    [mockArray removeAllObjects];
    
    match ([mockArray removeAllObjects]);
}

- (void)testMatchWillFailWhenItDoesNotFindCalls
{
    // if you try to match a method that has never been called it will fail
    
    ThisWillFail({
        match ([mockArray removeAllObjects]);
    });
}

- (void)testTooManyInvocationsAreIgnoredByMatch
{
    // by default, match will just check if a given method was at least called once
    // any further invocations are simply ignored
    
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    match ([mockArray removeAllObjects]); // too many invocations are ok
}

- (void)testYouCanMatchMultipleTimesToCheckMutlipleCalls
{
    // if you wan to test that a method was called multiple times just repeat the match call
    // (you can also use a modifier to match, see ExamplesMatch+Modifiers.m)
    
    [mockArray removeAllObjects];
    [mockArray removeAllObjects];
    
    match ([mockArray removeAllObjects]);
    match ([mockArray removeAllObjects]); // checks that the method was called at least 2 times
}

- (void)testMatchingTheSameCallTwiceFails
{
    // from the example above follows that if you try to match a call that was matched already
    // then the second match will fail
    
    [mockArray removeAllObjects];
    
    match ([mockArray removeAllObjects]);
    
    ThisWillFail({
        match ([mockArray removeAllObjects]);
    });
}

@end
